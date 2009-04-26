use inc::Module::Install;

name 'App::MusicBrainz::Collector';
all_from 'lib/App/MusicBrainz/Collector.pm';

requires 'Cwd';
requires 'DBD::SQLite';
requires 'File::Find::Rule';
requires 'File::HomeDir';
requires 'HTTP::Request::Common';
requires 'KiokuDB';
requires 'KiokuDB::Backend::DBI';
requires 'LWP::UserAgent';
requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'MooseX::Params::Validate';
requires 'MP3::Tag';
requires 'Path::Class';
requires 'SQL::Translator';

install_script 'collections';

auto_install;
WriteAll;
