use inc::Module::Install;

name 'MusicBrainz::Collections';
abstract 'Manage your MusicBrainz collection from local music files';
author 'Mustaqil Ali';
version '0.01';
license 'perl';
perl_version '5.00800';

requires 'DBI';
requires 'Cwd';
requires 'MP3::Tag';
requires 'File::Next';
requires 'LWP::UserAgent';
requires 'HTTP::Request::Common';

install_script 'collections';

auto_install;

WriteAll;
