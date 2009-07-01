use MooseX::Declare;

class ReactionX::Jumpstart 
    with ReactionX::Jumpstart::Generating 
    with ReactionX::Jumpstart::Namespacing
    with ReactionX::Jumpstart::SubBuilding
    with ReactionX::Jumpstart::Stashing {

    use MooseX::Types::Moose qw( Str Object );
    use Path::Class          qw( dir );

    use signatures;

    use aliased 'ReactionX::Jumpstart::Application';
    use aliased 'ReactionX::Jumpstart::Config';


    has application_builder => (
        isa         => Object,
        required    => 1,
        lazy_build  => 1,
        handles     => { build_application => 'JUMPSTART' },
    );

    has config_builder => (
        isa         => Object,
        required    => 1,
        lazy_build  => 1,
        handles     => { build_config => 'JUMPSTART' },
    );


    method JUMPSTART {

        $self->build_application;
        $self->build_config;
    }

    method find_root_path {

        my $project = $self->project_namespace;
        $project =~ s{::}{-}g;

        return dir( 'test', lc $project );
    }

    method _build_application_builder {

        my $project = $self->project_namespace;
        my $ui      = $self->ui_namespace;

        $self->set_stash(
            project_namespace => $project,
            ui_namespace      => $ui,
        );

        return $self->new_sub_builder(Application);
    }

    method _build_config_builder {

        return $self->new_sub_builder(Config);
    }
}
