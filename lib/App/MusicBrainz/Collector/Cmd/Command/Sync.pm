package App::MusicBrainz::Collector::Cmd::Command::Sync;
use Moose;

use File::Find::Rule;
use LWP::UserAgent;
use MooseX::Getopt;
use Set::Object qw( set );
use XML::Simple;

use App::MusicBrainz::Collector::Parsers;
use App::MusicBrainz::Collector::Release;
use App::MusicBrainz::Collector::Track;

extends 'App::MusicBrainz::Collector::Cmd::Base';

with 'App::MusicBrainz::Collector::WithLwp';

has 'remote_mbids' => (
    isa     => 'Set::Object',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_remote_mbids',
    traits  => [qw/ NoGetopt /],
);

has 'missing_local' => (
    isa     => 'Set::Object',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_missing_local',
    traits  => [qw/ NoGetopt /],
);

has 'missing_remote' => (
    isa     => 'Set::Object',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_missing_remote',
    traits  => [qw/ NoGetopt /],
);

has 'host' => (
    isa => 'Str',
    is  => 'rw',
    default => 'musicbrainz.org'
);

has 'skip_remote' => (
    isa => 'Bool',
    is  => 'rw'
);

sub run {
    my ($self, $opts, $args) = @_;

    my $scope = $self->kioku->new_scope;
    my $host = $self->host;

    App::MusicBrainz::Collector::Parsers->register_parser(
        'flac' => 'App::MusicBrainz::Collector::Parser::FLAC'
    );

    # Update our database with entries that we don't have locally
    print "Syncronizing local collection\n";
    unless ($self->skip_remote) {
        for my $release_id (@{ $self->missing_local }) {
            print "Adding $release_id to local collection\n";
            my $response = $self->lwp->get("http://$host/ws/1/release/$release_id?type=xml&inc=tracks+artist");

            if (!$response->is_success) {
                print "Couldn't lookup $release_id\n";
                next;
            }

            my $rel = XMLin($response->content, GroupTags => { 'track-list' => 'track' });
            for my $track_id (keys %{ $rel->{release}->{'track-list'} })
            {
                my $track = $self->kioku->lookup($track_id);

                if (!$track) {
                    my $track = App::MusicBrainz::Collector::Track->new(
                        mbid    => $track_id,
                        release => $release_id,
                        name    => $rel->{release}->{'track-list'}->{$track_id}->{title},
                        artist  => $rel->{release}->{artist}->{name} ||
                            $rel->{release}->{'track-list'}->{$track_id}->{artist}->{name},
                    );

                    $self->kioku->store($track_id => $track);
                }
            }
        }
    }

    # Check all our local copies for anything new...
    my @ext = App::MusicBrainz::Collector::Parsers->known_extensions;
    my $isa_folder = sub { $_->isa('App::MusicBrainz::Collector::Folder') };
    my $folders = $self->kioku->grep($isa_folder);

    for my $folder ($folders->items) {
        print "Syncing ", $folder->path, "...\n";
        my @files = File::Find::Rule->file->name(map { "*.$_" } @ext)->in($folder->path);

        for my $file (@files) {
            my $track_id = App::MusicBrainz::Collector::Parsers->parse_track_id($file)
                or next;

            my $track = $self->kioku->lookup($track_id);
            next if (defined $track && $track->release && $track->path);

            if (!$track) {
                $track = App::MusicBrainz::Collector::Track->new;
                $self->kioku->store($track_id => $track);
            }

            my $release_id = App::MusicBrainz::Collector::Parsers->parse_release_id($file);
            $track->path($file);
            $track->mbid($track_id);
            $track->release($release_id) if $release_id;

            $self->kioku->store($track);
        }
    }

    # Update the remote side with things
    print "Syncronizing local collection\n";
    for my $release_id ($self->missing_remote->elements) {
        my $req = "http://$host/ws/1/collection/?addAlbums=";
        $req .= join ",", $self->missing_remote->elements;

        my $response = $self->lwp->get($req);

        if (!$response->is_success) {
            print "Failed to sync releases:\n\t";
            print join "\n\t", $self->missing_remote->elements;
            print "\nError: ", $response->status_line, "\n";
        }
        else {
            print $response->content;
        }
    }
};

sub _build_remote_mbids {
    my $self = shift;

    print "Searching...\n";

    my $host = $self->host;
    my $response = $self->lwp->get("http://$host/ws/1/collection");

    print "Done, synchronizing with local database\n";

    die "Could not fetch collections from $host: ", $response->status_line
        unless $response->is_success;

    my $xml = XMLin($response->content);
    return set(keys %{ $xml->{'release-list'}->{release} });
}

sub _build_missing_local {
    my $self = shift;
    my $scope = $self->kioku->new_scope;

    my @missing;
    for my $mbid (@{ $self->remote_mbids }) {
        my $releases = $self->kioku->search({ release => "$mbid"});
        push @missing, $mbid
            if !$releases->items;
    }

    print "Found ", scalar @missing, " releases not in local collection\n";
    return set(@missing);
}

sub _build_missing_remote {
    my $self = shift;
    my $scope = $self->kioku->new_scope;

    my $missing_tracks = $self->kioku->grep(sub {
        $_->isa('App::MusicBrainz::Collector::Track') &&
                $_->path
    });

    my $tracks = set(map { $_->release } $missing_tracks->all);

    print "Found ", $tracks->size, " not in remote collection\n";
    return $tracks;
}

1;
