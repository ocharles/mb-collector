package App::MusicBrainz::Collector::Cmd::Command::Add;
use Moose;

use App::MusicBrainz::Collector::Folder;
use Cwd;
use Path::Class;

extends 'App::MusicBrainz::Collector::Cmd::Base';

sub run {
    my ($self, $opts, $args) = @_;

    my $path = (join ' ', @$args) || getcwd;
    my $pc = dir($path);
    $path = $pc->absolute->stringify;

    unless (-d $path) {
        print "The path '$path' does not exist (or couldn't be accessed)\n";
        return
    }

    my $f = App::MusicBrainz::Collector::Folder->new(path => $path);

    my $scope = $self->kioku->new_scope;
    $self->kioku->store($f);

    print "Added '$path' to collections. Please re-run sync to update files!\n";
};

1;

=head1 NAME

App::MusicBrainz::Collector::Cmd::Command::AddFolder - add a
new folder to your collection

=head1 SYNOPSIS

    % collections add ~/music

=head1 DESCRIPTION

Allows you to add a new folder to your collection

=cut
