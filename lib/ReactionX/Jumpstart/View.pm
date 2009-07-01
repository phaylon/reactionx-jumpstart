use MooseX::Declare;

class ReactionX::Jumpstart::View
    with ReactionX::Jumpstart::Generating
    with ReactionX::Jumpstart::Stashing
    with ReactionX::Jumpstart::SubBuilding
    with ReactionX::Jumpstart::Namespacing {

    use MooseX::Types::Moose qw( Str );


    has view_namespace => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'Name of the View?',
        defaults_to => 'Site',
        help_info   => sub { 
            sprintf 'example: %s for %s::%s::View::%s',
                $_[1],
                $_[0]->project_namespace, 
                $_[0]->ui_namespace,
                $_[1],
        },
    );

    has skin_name => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => "Name of your application's Skin?",
        defaults_to => sub { 

            my $skin = lc join '::', $_[0]->project_namespace, $_[0]->ui_namespace;
            $skin =~ s{::}{_}g;

            return $skin;
        },
    );

    has base_skin_name => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => "Name of the Skin from which your Skin inherits?",
        defaults_to => '/Reaction/default',
    );


    method JUMPSTART {

        $self->jumpstart_view;
        $self->jumpstart_skin;
    }

    method jumpstart_skin {

        my $name = $self->skin_name;
        my $base = $self->base_skin_name;

        $self->set_stash(skin_name => $name);

        my $layout_path = $self->mkpath('share/skin', $name, 'layout');
        my $web_path    = $self->mkpath('share/skin', $name, 'web');

        $self->build_file(
            file        => $self->path_to_file('share/skin', $name, 'skin.conf'),
            template    => 'skin.conf',
            dist        => 'ReactionX-Jumpstart',
            vars        => {
                base_skin_name => $base,
            },
        );
    }

    method jumpstart_view {
        
        my $namespace = $self->stash->{site_view_name}
                      = $self->view_namespace;

        my $package = $self->stash->{site_view_class}
                    = join '::', 
                        $self->project_namespace,
                        $self->ui_namespace,
                        'View',
                        $namespace;

        $self->build_package(
            package     => $package,
            dist        => 'ReactionX-Jumpstart',
            template    => 'view',
        );

        $self->build_file(
            file        => $self->path_to_file('share/skin/defaults.conf'),
            dist        => 'ReactionX-Jumpstart',
            template    => 'defaults.conf',
        );
    }
}
