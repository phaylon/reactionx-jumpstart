use inc::Module::Install;

name            'ReactionX-Jumpstart';
all_from        'lib/ReactionX/Jumpstart.pm';

requires        'MooseX::Declare',              '0.22';
requires        'MooseX::Types',                '0.12';
requires        'Path::Class',                  '0.16';
requires        'signatures',                   '0.05';
requires        'aliased',                      '0.22';
requires        'Catalyst::Runtime',            '5.80004';
requires        'List::MoreUtils',              '0.22';
requires        'Class::Inspector',             '1.24';
requires        'Template',                     '2.20';
requires        'File::ShareDir',               '1.00';
requires        'Moose',                        '0.79';
requires        'MooseX::Types::Path::Class',   '0.05';
requires        'Data::Dump',                   '1.14';
requires        'Term::Prompt',                 '1.04';
requires        'Find::Lib',                    '0.06';
requires        'namespace::autoclean',         '0.05';
requires        'Reaction';

install_script  'reaction-jumpstart';
install_share;

WriteAll;
