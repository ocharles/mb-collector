package App::MusicBrainz::Collector;

use strict;
use warnings;

use 5.008;

=head1 NAME

App::MusicBrainz::Collector - Manage your MusicBrainz collection locally

=head1 VERSION

0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    collections help
    collections add ~/Music
    collections sync
    collections verify

=head1 DESCRIPTION

This app provides an interface between your computer and the MusicBrainz
collection API. It allows you to register folders to add to your collection, and
then one command to syncronize your local collection database with MusicBrainz.

A command is also provide called verify, which will check your local database
against all folders - making sure that you have all the files in your
collection.

=head1 AUTHOR

Original concept by Mustaqil 'Muz' Ali

Rewritten by Oliver Charles C<< oliver.g.charles@googlemail.com >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Oliver Charles, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
