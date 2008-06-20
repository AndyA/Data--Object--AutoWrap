#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw( cmpthese );
use lib qw( lib );

package MyData;
use strict;
use warnings;
use Data::Object::AutoWrap qw( data );
use lib qw( lib );

sub new {
    my ( $class, $data ) = @_;
    bless { data => $data }, $class;
}

sub foo { shift->{data}->{bar} }

package main;

my $data = { bar => 'is bar' };
my $obj = MyData->new( $data );

# Baseline: 880-900% slower

my $dummy;
cmpthese(
    1_000_000,
    {
        foo => sub { $dummy = $obj->foo },
        bar => sub { $dummy = $obj->bar },
    }
);
