use MooseX::Declare;

class ReactionX::Jumpstart::Controller::Root
    extends ReactionX::Jumpstart::Controller {


    use MooseX::Types::Moose qw( Str Bool Object );

    use aliased 'ReactionX::Jumpstart::ViewGroup';


    has '+controller_namespace' => (defaults_to => 'Root');

    has site_layout_is_pushed => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Bool,
        question    => 'Do you want a base action to push the SiteLayout ViewPort?',
        defaults_to => 1,
    );

    has site_layout_is_customized => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Bool,
        question    => 'Do you want a customized SiteLayout ViewPort, Widget and LayoutSet?',
        defaults_to => 1,
    );

    has site_layout_group_builder => (
        isa         => Object,
        required    => 1,
        lazy_build  => 1,
        handles     => { build_site_layout_group => 'JUMPSTART' },
    );


    method _build_base_controller_namespace { 'Reaction::UI::Controller::Root' }

    method _build_base_chained_to { '/' }

    method _build_base_path_part { '' }

    method _build_site_layout_group_builder {

        return $self->new_sub_builder(ViewGroup,
            additional  => { 
                view_group_name         => 'SiteLayout',
                viewport_builder_args   => {
                    viewport_base_class     => 'Reaction::UI::ViewPort::SiteLayout',
                },
                widget_builder_args     => {
                    widget_base_class       => 'Reaction::UI::Widget::SiteLayout',
                },
                layout_set_builder_args => {
                    base_layout_set_name    => 'site_layout',
                    layout_set_is_extension => 1,
                    widget_name_is_explicit => 1,
                },
            },
        );
    }


    around render_config (HashRef $config) {

        return $self->$orig({
            %$config,
            namespace       => '',
            view_name       => $self->stash->{site_view_name},
        });
    }

    around build_controller_package (%args) {

        my $push_site_layout = $args{vars}{site_layout_is_pushed} 
                           ||= $self->site_layout_is_pushed;

        if ($push_site_layout) {

            my $is_customized = $args{vars}{site_layout_is_customized}
                            ||= $self->site_layout_is_customized;

            if ($is_customized) {

                $self->build_site_layout_group;
                $self->set_stash(site_layout_class => join '::',
                    $self->project_namespace,
                    $self->ui_namespace,
                    'ViewPort::SiteLayout',
                );
            }
            else {

                $self->set_stash(site_layout_class => 'Reaction::UI::ViewPort::SiteLayout');
            }
        }

        return $self->$orig(%args);
    }

    after JUMPSTART {
        $self->set_stash(root_controller_namespace => $self->controller_namespace);
    }
}
