package MusicBrainz::Parser;
use Moose;

=head1 NAME

MusicBrainz::Parser - abstract base class for all parsers.

=head1 DESCRIPTION

The base class for specific file type parsers. Make sure to implement
marked methods!

=head1 METHODS

=head2 parse -- must be implemented

Given a $file, attempt to parse it and return the release mbid.

=cut

sub parse
{
    my ($self, $file) = @_;
    die;
}

1;
