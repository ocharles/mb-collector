package App::MusicBrainz::Collector::WithLwp;
use Moose::Role;

with 'App::MusicBrainz::Collector::WithUser';

has 'lwp' => (
    isa     => 'LWP::UserAgent',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_lwp'
);

has 'no_proxy' => (
    isa => 'Bool',
    is  => 'rw',
);

sub _build_lwp
{
    my $self = shift;

    my $lwp = LWP::UserAgent->new;
    $lwp->env_proxy unless $self->no_proxy;

    $lwp->credentials(
        'musicbrainz.org:80',
        'musicbrainz.org',
        $self->username => $self->password
    );

    return $lwp;
}

1;
