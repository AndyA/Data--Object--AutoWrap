#!perl
# vim:ts=4:sw=4:et:ft=perl:

require 5.008001;    # C'mon - it's the future right now.

use strict;
use warnings;
use ExtUtils::MakeMaker;

eval 'use ExtUtils::MakeMaker::Coverage';

WriteMakefile(
  ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
  license( 'perl' ),
  NAME          => 'Data::Object::AutoWrap',
  AUTHOR        => 'Andy Armstrong <andy.armstrong@messagesystems.com>',
  VERSION_FROM  => 'lib/Data/Object/AutoWrap.pm',
  ABSTRACT_FROM => 'lib/Data/Object/AutoWrap.pm',
  PL_FILES      => {},
  PREREQ_PM     => {
    'Test::More'   => 0,
    'Scalar::Util' => 0
  },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES    => 'Data-Object-AutoWrap-*' },
);

sub license {
  my $lic = shift;
  local $^W = 0;    # Silence warning about non-numeric version
  return
   unless $ExtUtils::MakeMaker::VERSION >= '6.31';
  return ( LICENSE => $lic );
}
