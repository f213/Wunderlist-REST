use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Wunderlist::REST',
    AUTHOR           => q{Fedor Borshev <fedor9@gmail.com>},
    VERSION_FROM     => 'lib/Wunderlist/REST.pm',
    ABSTRACT_FROM    => 'lib/Wunderlist/REST.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
	'Badger::Class'	=> 0,
	'Rose::URI'	=> 0,
	'JSON::XS'	=> 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Wunderlist-REST-*' },
);
