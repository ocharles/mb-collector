package MusicBrainz::Collections;
use Moose;

use LWP::UserAgent;
use MooseX::Params::Validate;
use MooseX::Types::Path::Class qw(Dir);
use MP3::Tag;
use HTTP::Request::Common qw(POST);

with 'MooseX::Getopt';

=head1 NAME

MusicBrainz::Collections - support scanning a media folder
for tagged music, and adding it to your MusicBrainz collection

=head1 DESCRIPTION

This module implements a small API to scan a folder full of music,
and submit each unique release (defined by a unique MusicBrainz release ID)
to the MusicBrainz web service, to add to a users collection.

=head1 ATTRIBUTES

=head2 user_name

The name of the user (at MusicBrainz.org).

=cut

has 'user_name' => (
    is          => 'rw',
    isa         => 'Str',
    traits      => [ 'Getopt' ],
    required    => 1,
    cmd_aliases => 'u',
);

=head2 password

The users password on MusicBrainz.org

=cut

has 'password' => (
    is          => 'rw',
    isa         => 'Str',
    traits      => [ 'Getopt' ],
    required    => 1,
    cmd_aliases => 'p',
);

=head1 METHODS

=head2 releases

Find all unique releases in a directory, and return an array ref of
MusicBrainz IDs.

=cut

sub releases
{
    my ($self, $root) = validatep(\@_,
        root => {
            isa    => Dir,
            coerce => 1,
        }
    );
    
    my @mbids;
    $root->recurse(callback => sub {
        my $e = shift;
        
        return if $e->is_dir;
        
        my $mp3 = MP3::Tag->new($e->absolute);
        my $mbid = $mp3->select_id3v2_frame_by_descr('TXXX[MusicBrainz Album Id]');
        
        push @mbids, $mbid
            if $mbid;
    });
    
    return \@mbids;
}

=head2 add_releases

Submit an array ref of release mbids to MusicBrainz

=cut

sub add_releases
{
    my ($self, $releases) = validatep(\@_,
        releases => { isa => 'ArrayRef[Str]' }
    );

    my $ua = LWP::UserAgent->new;
    $ua->env_proxy;
    $ua->credentials(
        'musicbrainz.org:80',
        'musicbrainz.org',
        $self->user_name,
        $self->password
    );
    
    my $req = POST "http://musicbrainz.org/ws/1/collection/", [
        addAlbums => join ",", @$releases
    ];
    my $request = $ua->request($req);
    
    print $request->status_line;
}

1;
