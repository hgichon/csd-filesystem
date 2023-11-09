package GMS::Exception::CreateFailure;

use v5.14;

use strict;
use warnings;
use utf8;

our $AUTHORITY = 'cpan:gluesys';

use Mouse;
use namespace::clean -except => 'meta';

#---------------------------------------------------------------------------
#   Inheritances
#---------------------------------------------------------------------------
extends 'GMS::Exception::Base';

#---------------------------------------------------------------------------
#   Attributes
#---------------------------------------------------------------------------
has '+status' => (default => 500,);

has '+code' => (default => 'CREATE_FAILURE',);

has '+message' => (
    default => sub
    {
        my $self = shift;

        sprintf(
            'Failed to create %s: %s',
            ucfirst($self->resource),
            $self->name
        );
    },
    lazy => 1,
);

has '+msgargs' => (
    lazy    => 1,
    default => sub
    {
        my $self = shift;

        [resource => lc($self->resource), name => $self->name];
    }
);

has 'resource' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
1;

=encoding utf8

=head1 NAME

GMS::Exception::CreateFailure - 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Ji-Hyeon Gim E<lt>potatogim@gluesys.comE<gt>

=head1 CONTRIBUTORS

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2021. Gluesys Co., Ltd. All rights reserved.

=head1 SEE ALSO

=cut

