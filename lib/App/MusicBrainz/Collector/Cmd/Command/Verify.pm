package App::MusicBrainz::Collector::Cmd::Command::Verify;
use Moose;

use LWP::UserAgent;
use XML::Simple;

extends 'App::MusicBrainz::Collector::Cmd::Base';

sub run {
    my $self = shift;

    my $scope = $self->kioku->new_scope;
    my $tracks = $self->kioku->search({ path => undef });

    print "The following tracks could not be found locally:";
    until ($tracks->is_done)
    {
        for my $track ($tracks->items) {
            printf "[%s]: %s - %s\n", $track->mbid, $track->artist, $track->name;
        }
    }
}

1;
