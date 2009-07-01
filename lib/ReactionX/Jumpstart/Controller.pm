use MooseX::Declare;

class ReactionX::Jumpstart::Controller 
    with ReactionX::Jumpstart::Namespacing
    with ReactionX::Jumpstart::Generating
    with ReactionX::Jumpstart::SubBuilding
    with ReactionX::Jumpstart::Stashing {
    
    use MooseX::Types::Moose qw( Str Bool Object );
    use Data::Dump           qw( pp );


    has controller_namespace => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'Name of the Controller?',
        help_info   => sub { 
            sprintf 'example: %s for %s::%s::Controller::%s',
                $_[1] || 'Foo',
                $_[0]->project_namespace, 
                $_[0]->ui_namespace,
                $_[1] || 'Foo',
        },
    );

    has base_controller_namespace => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'ClassName of base Controller?',
        defaults_to => 'Reaction::UI::Controller',
    );

    has base_chained_to => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'To what action is the base action chained?',
        help_info   => 'via private path, e.g. /foo/bar',
        defaults_to => '/',
    );

    has base_path_part => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'What is the base (public) path part for this Controller?',
        defaults_to => sub { lc( ( split /::/, $_[0]->base_controller_namespace )[-1] ) },
    );

    
    method JUMPSTART {

        my $controller_namespace = join '::',
            $self->project_namespace,
            $self->ui_namespace,
            'Controller',
            $self->controller_namespace;

        my $base_namespace  = $self->base_controller_namespace;
        my $base_chained_to = $self->base_chained_to;
        my $base_path_part  = $self->base_path_part;
        my $config_partial  = $self->render_config({});

        $self->build_controller_package(
            package     => $controller_namespace,
            dist        => 'ReactionX-Jumpstart',
            template    => 'controller',
            vars        => {
                controller_package  => $controller_namespace,
                controller_base     => $base_namespace,
                controller_config   => $config_partial,
                base_chained_to     => $base_chained_to,
                base_path_part      => $base_path_part,
            }
        );
    }

    method render_config (HashRef $config) {

        return join "\n", map {
            sprintf '%s => %s,',
                pp($_),
                pp($config->{ $_ }),
        } keys %$config;
    }

    method build_controller_package (%args) { $self->build_package(%args) }
}
