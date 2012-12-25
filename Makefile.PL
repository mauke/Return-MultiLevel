use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Return::MultiLevel',
    AUTHOR              => q{Lukas Mai <l.mai@web.de>},
    VERSION_FROM        => 'lib/Return/MultiLevel.pm',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '6.56',
    },
    LICENSE => 'perl',
    PL_FILES            => {},
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'warnings' => 0,
        'strict' => 0,
        'base' => 0,
        'Exporter' => 0,
        'Scope::OnExit::Wrap' => 0,
        'Carp' => 0,
    },
    MIN_PERL_VERSION => '5.6.0',
    META_MERGE => {
        resources => {
            repository => {
                url => 'git://github.com/mauke/Return-MultiLevel.git',
                web => 'https://github.com/mauke/Return-MultiLevel',
                type => 'git',
            },
        },
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Return-MultiLevel-*' },
);
