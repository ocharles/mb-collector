package App::MusicBrainz::Collector::Release;
use Moose;
use MooseX::AttributeHelpers;

has 'name' => (
    isa => 'Str',
    is  => 'rw'
);

has 'mbid' => (
    isa => 'Str',
    is  => 'rw',
);

has 'tracks' => (
    metaclass => 'Collection::Array',
    isa       => 'ArrayRef[App::MusicBrainz::Collector::Track]',
    is        => 'rw',
    default   => sub { [] },
    provides  => {
        push => 'add_track',
    }
);

1;
