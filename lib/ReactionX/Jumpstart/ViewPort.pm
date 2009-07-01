use MooseX::Declare;

class ReactionX::Jumpstart::ViewPort
    with ReactionX::Jumpstart::Generating
    with ReactionX::Jumpstart::Stashing
    with ReactionX::Jumpstart::SubBuilding
    with ReactionX::Jumpstart::Namespacing {

    use MooseX::Types::Moose qw( Str );


    has viewport_namespace => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'Name of the ViewPort?',
        help_info   => sub { 
            sprintf '%s for %s::%s::ViewPort::%s',
                $_[1] || 'Foo',
                $_[0]->project_namespace, 
                $_[0]->ui_namespace,
                $_[1] || 'Foo',
        },
    );

    has viewport_base_class => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => "ClassName of the ViewPort's parent?",
        defaults_to => 'Reaction::UI::ViewPort',
    );


    method JUMPSTART {

        my $package = join '::',
            $self->project_namespace,
            $self->ui_namespace,
            'ViewPort',
            $self->viewport_namespace;

        my $parent  = $self->viewport_base_class;

        $self->build_package(
            package     => $package,
            dist        => 'ReactionX-Jumpstart',
            template    => 'viewport',
            vars        => {
                viewport_package => $package,
                viewport_base    => $parent,
            },
        );
    }
}
