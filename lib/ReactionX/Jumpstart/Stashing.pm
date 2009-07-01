use MooseX::Declare;

role ReactionX::Jumpstart::Stashing {

    use MooseX::Types::Moose qw( HashRef );


    my $singleton_stash = {};

    has stash => (is => 'ro', isa => HashRef, required => 1, default => sub { $singleton_stash });


    method set_stash (%pairs) {

        $self->stash->{ $_ } = $pairs{ $_ }
            for keys %pairs;
    }
}
