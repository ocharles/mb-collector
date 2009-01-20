package MusicBrainz::Parsers;
use MooseX::Singleton;

use MooseX::Params::Validate;
use MooseX::Types::Path::Class qw(File);

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
    default => sub { +{} }
);

=head1 METHODS

=head2 release_mbid

Try and determine the release MBID for a file, using various parsers.

=cut

sub release_mbid
{
    my $self = shift;
    my ($file) = validatep(\@_,
        file => { isa => File }
    );
    
    my ($extension) = ($file->basename =~ /.*\.(.*)/);
    return unless $extension;

    if ($self->parsers->{$extension})
    {
        return $self->parsers->{$extension}->parse($file);
    }
    else
    {
        return;
    }
}

=head2 register_parser

Register a parser for a given file_type

=cut

sub register_parser
{
    my $self = shift;
    my ($extension, $parser) = validatep(\@_,
        extension => { isa => 'Str' },
        parser    => { isa => 'MusicBrainz::Parser' },
    );

    $self->parsers->{$extension} = $parser;
}

1;
