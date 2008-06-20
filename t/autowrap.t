#!perl
use strict;
use warnings;
use Test::More tests => 11;
use Test::Deep;

package MyData;
use Data::Object::AutoWrap qw( data );
use strict;
use warnings;

sub new {
    my ( $class, $data ) = @_;
    bless { data => $data }, $class;
}

package main;

{
    ok my $d = MyData->new(
        {
            one   => 1,
            two   => 2,
            three => 3,
            hash  => {
                smaller => '><',
                larger  => '<>',
            },
        }
      ),
      'new';

    isa_ok $d, 'MyData';
    is $d->one,   1, 'one';
    is $d->two,   2, 'two';
    is $d->three, 3, 'three';
    eval { $d->four };
    like $@,
      qr{Undefined subroutine &MyData::four called at \S+autowrap\.t line \d+},
      'four';

    ok my $hash = $d->hash, 'hash';
    isa_ok $hash, 'Data::Object::AutoWrap::Hash';
    is $hash->smaller, '><', 'smaller';

    is $d->hash->smaller, '><', 'smaller';
    is $d->hash->larger,  '<>', 'larger';

    # TODO: Why doesn't this work?
    # cmp_deeply( $d, methods( one => 1, two => 2, three => 3 ) );
}

# vim:ts=4:sw=4:et:ft=perl:
