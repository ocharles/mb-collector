package App::MusicBrainz::Collector::Cmd::Base;
use Moose;

use File::HomeDir qw( my_home );
use KiokuDB;
use MooseX::Getopt;

extends 'MooseX::App::Cmd::Command';

has 'kioku' => (
    isa => 'KiokuDB',
    is  => 'rw',
    traits => [qw/NoGetopt/],
    builder => '_build_kioku',
    lazy => 1,
);

sub _build_kioku
{
    KiokuDB->connect(
        sprintf("dbi:SQLite:dbname=%s/.mb-collection.db", my_home),
        columns => [
            path => {
                data_type => 'varchar',
                is_nullable => 1,
            },
            'release' => {
                data_type => 'varchar',
                is_nullable => 1,
            }
        ],
        create => 1
    ) or die "Could not connect to Genius KiokuDB";
}

sub run { }

1;
