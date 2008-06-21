#!perl
use strict;
use warnings;
use Test::More tests => 27;
use Test::Deep;
use lib qw( t/lib );
use Utils;

package MyData;
use strict;
use warnings;
use Data::Object::AutoWrap qw( data );

sub new {
    my ( $class, $data ) = @_;
    bless { data => $data }, $class;
}

package main;

{
    my $chunk = { name => 'chunk', hours => [ 3, 6, 9, 12 ] };
    my $data = {
        one   => 1,
        two   => 2,
        three => 3,
        hash  => {
            smaller => '>|<',
            larger  => '< >',
        },
        array => [
            1, 'string',
            {
                here  => 'there',
                array => [ 'one', 'two', 'three' ],
                chunk => $chunk
            },
            [ 2, 3, 4, ],
            $chunk,
        ],
        chunk => $chunk,
    };

    my $snap = bake( $data );
    # diag $snap;
    ok my $d = MyData->new( $data ), 'new';
    isa_ok $d, 'MyData';
    can_ok $d, 'one';
    can_ok $d, 'new';
    is $d->one,   1, 'one';
    is $d->two,   2, 'two';
    is $d->three, 3, 'three';
    eval { $d->four };
    like $@,
      qr{Undefined subroutine &MyData::four called at \S+autowrap\.t line \d+},
      'four';

    ok my $hash = $d->hash, 'hash';
    isa_ok $hash, 'Data::Object::AutoWrap::Hash';
    is $hash->smaller, '>|<', 'smaller';

    is $d->hash->smaller, '>|<', 'smaller';
    is $d->hash->larger,  '< >', 'larger';
    can_ok $d->hash, 'larger';

    is $d->array( 0 ), 1, 'array -> scalar';
    is $d->array( 3, 0 ), 2, 'array -> array -> scalar';
    is $d->array( 2 )->here, 'there', 'array -> hash -> scalar';
    is $d->array( 2, 'here' ), 'there', 'array -> hash -> scalar 2';
    is $d->array( 2 )->array( 2 ), 'three',
      'array -> hash -> array -> scalar';
    is $d->array( 2, 'array', 2 ), 'three',
      'array -> hash -> array -> scalar 2';

    # Reused chunk
    is $d->chunk->name, 'chunk', 'chunk';
    is $d->chunk->hours( 1 ), 6, 'hours';
    is $d->array( 4 )->name, 'chunk', 'chunk 2';
    is $d->array( 4 )->hours( 1 ), 6, 'hours 2';
    is $d->array( 2 )->chunk->name, 'chunk', 'chunk 3';
    is $d->array( 2 )->chunk->hours( 1 ), 6, 'hours 3';

    is bake( $data ), $snap, 'data unmolested';

    # TODO: Why doesn't this work?
    # cmp_deeply( $d, methods( one => 1, two => 2, three => 3 ) );
}

# vim:ts=4:sw=4:et:ft=perl:
