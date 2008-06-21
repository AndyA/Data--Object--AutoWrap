#!perl
# vim:ts=4:sw=4:et:ft=perl:

use strict;
use warnings;
use ExtUtils::MakeMaker;

eval 'use ExtUtils::MakeMaker::Coverage';

WriteMakefile(
    ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
    NAME          => 'Data::Object::AutoWrap',
    AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
    LICENSE       => 'perl',
    VERSION_FROM  => 'lib/Data/Object/AutoWrap.pm',
    ABSTRACT_FROM => 'lib/Data/Object/AutoWrap.pm',
    PL_FILES      => {},
    PREREQ_PM     => { 'Test::More' => 0, },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Data-Object-AutoWrap-*' },
);
