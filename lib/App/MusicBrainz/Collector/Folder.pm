package App::MusicBrainz::Collector::Folder;
use Moose;

has 'path' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1
);

1;
