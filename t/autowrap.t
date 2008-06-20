#!perl
use strict;
use warnings;
use Test::More tests => 12;
use Test::Deep;
use lib qw( t/lib );
use Utils;

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
    my $data = {
        one   => 1,
        two   => 2,
        three => 3,
        hash  => {
            smaller => '>|<',
            larger  => '< >',
        },
    };

    my $snap = bake( $data );
    diag $snap;
    ok my $d = MyData->new( $data ), 'new';
    # diag bake( $d );
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

    is bake( $data ), $snap, 'data unmolested';

    # TODO: Why doesn't this work?
    # cmp_deeply( $d, methods( one => 1, two => 2, three => 3 ) );
}

# vim:ts=4:sw=4:et:ft=perl:
