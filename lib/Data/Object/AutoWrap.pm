package Data::Object::AutoWrap;

use warnings;
use strict;
use Carp qw( confess croak );

# use Data::Object::AutoWrap::Hash;

$Carp::CarpLevel = 1;

=head1 NAME

Data::Object::AutoWrap - Autogenerate accessors for R/O object data

=head1 VERSION

This document describes Data::Object::AutoWrap version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Data::Object::AutoWrap;
  
=head1 DESCRIPTION

=head1 INTERFACE 

=cut

sub _make_value_handler {
    my ( $class, $value ) = @_;
    if ( 'HASH' eq ref $value ) {
        # Delay loading so we're compiled before wrapper
        # attempts to use us.
        eval 'require Data::Object::AutoWrap::Hash';
        die $@ if $@;
        # TODO: Just bless (a copy of) the hash?
        return sub {
            my $self = shift;
            if ( @_ ) {
                my $key = shift;
                return $class->_make_value_handler( $value->{$key} )
                  ->( $self, @_ );
            }
            else {
                return Data::Object::AutoWrap::Hash->new( $value );
            }
        };
    }
    elsif ( 'ARRAY' eq ref $value ) {
        return sub {
            my $self = shift;
            return @$value
              if wantarray && @_ == 0;
            croak "Array accessor needs an index in scalar context"
              unless @_;
            my $idx = shift;
            return $class->_make_value_handler( $value->[$idx] )
              ->( $self, @_ );
        };
    }
    else {
        return sub {
            my $self = shift;
            croak "Scalar accessor takes no argument"
              if @_;
            return $value;
        };
    }
}

sub import {
    my $class = shift;
    my $pkg   = caller;

    my $get_data;
    if ( @_ ) {
        my $field = shift;
        # TODO: Allow a closure here so objects can be promises
        $get_data = sub { shift->{$field} };
    }
    else {
        $get_data = sub { shift };
    }

    no strict 'refs';
    *{"${pkg}::can"} = sub {
        my ( $self, $method ) = @_;
        my $data = $get_data->( $self );
        # TODO: can inheritance is wrong
        return
          exists $data->{$method}
          ? $class->_make_value_handler( $data->{$method} )
          : $pkg->SUPER::can( $method );
    };

    our $AUTOLOAD;
    *{"${pkg}::AUTOLOAD"} = sub {
        my $self = shift;
        ( my $field = $AUTOLOAD ) =~ s/.*://;
        return if $field eq 'DESTROY';
        if ( my $code = $self->can( $field ) ) {
            return $self->$code( @_ );
        }

        confess "Undefined subroutine &$AUTOLOAD called";
    };
}

1;

# vim:ts=4:sw=4:et:ft=perl:

__END__

=head1 CONFIGURATION AND ENVIRONMENT
  
Data::Object::AutoWrap requires no configuration files or environment
variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-data-object-autowrap@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Andy Armstrong  C<< <andy.armstrong@messagesystems.com> >>

=head1 LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

Copyright (c) 2008, Message Systems, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the following
conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the
      distribution.
    * Neither the name Message Systems, Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
