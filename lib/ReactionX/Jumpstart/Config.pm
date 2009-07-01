use MooseX::Declare;

class ReactionX::Jumpstart::Config
    with ReactionX::Jumpstart::Generating
    with ReactionX::Jumpstart::Stashing
    with ReactionX::Jumpstart::Namespacing {


    use Catalyst::Utils;


    method JUMPSTART {

        my $config_file = $self->path_to_file(
            'etc',
            Catalyst::Utils::appprefix(join '::', $self->project_namespace, $self->ui_namespace) . '.conf',
        );
        
        $self->build_file(
            file        => $config_file,
            dist        => 'ReactionX-Jumpstart',
            template    => 'application.conf',
        );
    }
}
