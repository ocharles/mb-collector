package App::MusicBrainz::Collector::Parsers;
use MooseX::Singleton;

use MooseX::AttributeHelpers;
use Path::Class qw( file );
use UNIVERSAL::require;

with 'App::MusicBrainz::Collector::Parser';

=head1 NAME

MusicBrainz::Parsers - factory to create a parser for a file, given its
file extension

=head1 DESCRIPTION

This is a singleton factory that tries to parse files based on their file
extension

=head1 ATTRIBUTES

=head2 parsers

A hash table of file-extensions to parser instances

=cut

has 'parsers' => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{} },
    metaclass => 'Collection::Hash',
    provides => {
        keys => 'known_extensions',
    }
);

=head1 METHODS

=head2 determine_release_mbid

Try and determine the release MBID for a file, using various parsers.

=cut

sub parse_release_id
{
    my $self = shift;
    my ($file) = @_;

    $file = file($file);

    $file = file($file);
    my ($extension) = ($file->basename =~ /.*\.(.*)$/);
    return unless $extension;

    if ($self->parsers->{$extension})
    {
        return $self->parsers->{$extension}->parse_release_id($file->absolute->stringify);
    }
    else
    {
        warn "No parser knows how to handle $extension";
        return;
    }
}

sub parse_track_id
{
    my $self = shift;
    my ($file) = @_;

    $file = file($file);
    my ($extension) = ($file->basename =~ /.*\.(.*)$/);
    return unless $extension;

    if ($self->parsers->{$extension})
    {
        return $self->parsers->{$extension}->parse_track_id($file->absolute->stringify);
    }
    else
    {
        warn "No parser knows how to handle $extension";
        return;
    }
}

=head2 register_parser

Register a parser for a given file_type

=cut

sub register_parser
{
    my $self = shift;
    my ($extension, $parser) = @_;

    $parser->require;
    $self->parsers->{$extension} = $parser;
}

1;
