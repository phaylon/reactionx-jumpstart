use MooseX::Declare;

class ReactionX::Jumpstart::Application 
    with ReactionX::Jumpstart::Generating 
    with ReactionX::Jumpstart::SubBuilding
    with ReactionX::Jumpstart::Namespacing
    with ReactionX::Jumpstart::Stashing {


    use MooseX::Types::Moose qw( Str Bool Object );
    use Catalyst::Runtime;
    use Reaction;

    use aliased 'ReactionX::Jumpstart::Controller::Root';
    use aliased 'ReactionX::Jumpstart::View';


    has application_name => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'Descriptive name of the application?',
        defaults_to => sub { my $name = $_[0]->project_namespace; $name =~ s{::}{-}g; $name },
    );

    has root_controller_is_built => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Bool,
        question    => 'Create a Root Controller?',
        help_info   => "The Controller managing '/'",
        defaults_to => 1,
    );

    has root_controller_builder => (
        isa         => Object,
        required    => 1,
        lazy_build  => 1,
        handles     => { build_root_controller => 'JUMPSTART' },
    );

    has view_builder => (
        isa         => Object,
        required    => 1,
        lazy_build  => 1,
        handles     => { build_view => 'JUMPSTART' },
    );


    method JUMPSTART {

        my $application_package = join '::', $self->project_namespace, $self->ui_namespace;
        my $application_name    = $self->application_name;

        $self->set_stash(
            application_package => $application_package,
            application_name    => $application_name,
        );

        $self->build_package(
            package     => $application_package,
            dist        => 'ReactionX-Jumpstart',
            template    => 'application',
            vars        => {
                catalyst_version    => Catalyst::Runtime->VERSION,
                reaction_version    => Reaction->VERSION,
            },
        );

        $self->build_view;

        if ($self->root_controller_is_built) {
            $self->build_root_controller;
        }
    }

    method _build_root_controller_builder { $self->new_sub_builder(Root) }

    method _build_view_builder { $self->new_sub_builder(View) }
}
