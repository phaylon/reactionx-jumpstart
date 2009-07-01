use MooseX::Declare;

class ReactionX::Jumpstart::Widget
    with ReactionX::Jumpstart::Generating
    with ReactionX::Jumpstart::Stashing
    with ReactionX::Jumpstart::SubBuilding
    with ReactionX::Jumpstart::Namespacing {

    use MooseX::Types::Moose qw( Str );


    has widget_namespace => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'Name of the Widget?',
        help_info   => sub { 
            sprintf '%s for %s::Widget::%s',
                $_[1] || 'Foo',
                $_[0]->stash->{site_view_class}, 
                $_[1] || 'Foo',
        },
    );

    has widget_base_class => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => "ClassName of the Widget's parent?",
        defaults_to => 'Reaction::UI::Widget',
    );


    method JUMPSTART {

        my $package = join '::',
            $self->stash->{site_view_class},
            'Widget',
            $self->widget_namespace;

        my $parent  = $self->widget_base_class;

        $self->build_package(
            package     => $package,
            dist        => 'ReactionX-Jumpstart',
            template    => 'widget',
            vars        => {
                widget_package => $package,
                widget_base    => $parent,
            },
        );
    }
}
