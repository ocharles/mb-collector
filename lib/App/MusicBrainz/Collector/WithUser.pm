package App::MusicBrainz::Collector::WithUser;
use Moose::Role;
use MooseX::Getopt;

has 'username' => (
    traits      => [qw/ Getopt /],
    isa         => 'Str',
    is          => 'ro',
    required    => 1,
    cmd_aliases => [qw/ u /],
);

has 'password' => (
    traits      => [qw/ Getopt /],
    isa         => 'Str',
    is          => 'ro',
    required    => 1,
    cmd_aliases => [qw/ p /],
);

no Moose::Role;
1;
