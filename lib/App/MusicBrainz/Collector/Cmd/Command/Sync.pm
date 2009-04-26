package App::MusicBrainz::Collector::Cmd::Command::Sync;
use Moose;

use LWP::UserAgent;
use XML::Simple;

use App::MusicBrainz::Collector::Release;
use App::MusicBrainz::Collector::Track;

extends 'App::MusicBrainz::Collector::Cmd::Base';

with 'App::MusicBrainz::Collector::WithLwp';

sub run {
    my ($self, $opts, $args) = @_;

    print "Searching...\n";
    my $response = $self->lwp->get('http://musicbrainz.org/ws/1/collection');
    print "Done, synchronizing with local database\n";

    die "Could not fetch collections"
        unless $response->is_success;

    my $xml = XMLin($response->content);
    my @all_mbids = keys %{ $xml->{'release-list'}->{release} };

    my $scope = $self->kioku->new_scope;

    my @to_sync;
    for my $mbid (@all_mbids) {
        my $releases = $self->kioku->search({ release => "$mbid"});
        push @to_sync, $mbid
            if !$releases->items;
    }

    print "Found ", scalar @to_sync, " missing releases\n";

    for my $release_id (@to_sync) {
        print "Adding $release_id\n";
        my $response = $self->lwp->get("http://musicbrainz.org/ws/1/release/$release_id?type=xml&inc=tracks+artist");

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

                $self->kioku->store("$track_id" => $track);
            }
        }
    }
};

1;
