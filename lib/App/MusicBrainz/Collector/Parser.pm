package App::MusicBrainz::Collector::Parser;
use Moose::Role;

=head1 NAME

MusicBrainz::Parser - abstract base class for all parsers.

=head1 DESCRIPTION

The base class for specific file type parsers. Make sure to implement
marked methods!

=head1 METHODS

=head2 parse

Given a $file, attempt to parse it and return the release mbid.

=cut

requires 'parse';

no Moose::Role;

1;
