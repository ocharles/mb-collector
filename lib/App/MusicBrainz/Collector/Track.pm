package App::MusicBrainz::Collector::Track;
use Moose;

has 'mbid' => (
    isa => 'Str',
    is  => 'rw'
);

has 'path' => (
    isa => 'Str',
    is  => 'rw'
);

has 'release' => (
    isa => 'Str',
    is  => 'rw'
);

has [qw/ artist name /] => (
    isa => 'Str',
    is  => 'rw',
);

1;
