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
requires 'Path::Class';
requires 'SQL::Translator';

feature 'FLAC support',
    'Music::Tag', 'Music::Tag::FLAC', 'Text::Levenshtein';

feature 'MP3 support',
    'MP3::Tag';

install_script 'collections';

auto_install;
WriteAll;
