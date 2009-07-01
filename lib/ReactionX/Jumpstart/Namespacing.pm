use MooseX::Declare;

role ReactionX::Jumpstart::Namespacing {

    use MooseX::Types::Moose qw( Str Object );

    has project_namespace => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        required    => 1,
        question    => 'Namespace of the project?',
        help_info   => 'example: MyApp',
    );

    has ui_namespace => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'Name of the UI?',
        defaults_to => 'Web',
        help_info   => sub { sprintf 'example: %s for %s::%s', $_[1], $_[0]->project_namespace, $_[1] },
    );
}
