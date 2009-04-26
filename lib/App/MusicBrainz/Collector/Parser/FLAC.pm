package App::MusicBrainz::Collector::Parser::FLAC;
use Moose;

use Audio::FLAC::Header;

with 'App::MusicBrainz::Collector::Parser';

sub parse_release_id {
    my ($self, $file) = @_;
    return $self->_get_info($file)->{musicbrainz_albumid}
}

sub parse_track_id {
    my ($self, $file) = @_;
    return $self->_get_info($file)->{musicbrainz_trackid};
}

sub _get_info {
    my ($self, $file) = @_;
    die if not $file;

    my $flac = Audio::FLAC::Header->new($file);
    return $flac->tags;
}

1;
