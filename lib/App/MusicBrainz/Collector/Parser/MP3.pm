package App::MusicBrainz::Collector::Parser::MP3;
use Moose;
with 'App::MusicBrainz::Collector::Parser';

use MooseX::Params::Validate;
use MooseX::Types::Path::Class qw(File);
use MP3::Tag;

=head1 NAME

MusicBrainz::Parser::MP3 - parse mp3 files with MP3::Tag

=head1 DESCRIPTION

This attempts to fetch the release ID from an mp3, using L<MP3::Tag>

=head1 METHODS

=head2 parse

Parse a file as an MP3, if possible

=cut

override 'parse' => sub
{
    my ($self, $file) = @_;

    my $mp3 = MP3::Tag->new($file->absolute);
    my $mbid = $mp3->select_id3v2_frame_by_descr('TXXX[MusicBrainz Album Id]');

    return $mbid;
};

1;
