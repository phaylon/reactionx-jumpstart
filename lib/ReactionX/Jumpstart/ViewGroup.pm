use MooseX::Declare;

class ReactionX::Jumpstart::ViewGroup
    with ReactionX::Jumpstart::Generating
    with ReactionX::Jumpstart::Stashing
    with ReactionX::Jumpstart::SubBuilding
    with ReactionX::Jumpstart::Namespacing {


    use MooseX::Types::Moose qw( Str Object HashRef );
    use Reaction::UI::View;

    use aliased 'ReactionX::Jumpstart::ViewPort';
    use aliased 'ReactionX::Jumpstart::Widget';
    use aliased 'ReactionX::Jumpstart::LayoutSet';


    has view_group_name => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'Name of the group?',
        help_info   => sub {
            my ($self, $default) = @_;

            $default ||= 'Foo';

            sprintf '%s for ViewPort::%s, Widget::%s, layout/%s.tt',
                ($default) x 3,
                Reaction::UI::View->layout_set_name_from_viewport("DUMMY::ViewPort::$default"),
        },
    );

    has viewport_builder => (
        isa         => Object,
        required    => 1,
        lazy_build  => 1,
        handles     => { build_viewport => 'JUMPSTART' },
    );

    has viewport_builder_args => (
        is          => 'rw',
        isa         => HashRef,
        required    => 1,
        default     => sub { {} },
    );

    has widget_builder => (
        isa         => Object,
        required    => 1,
        lazy_build  => 1,
        handles     => { build_widget => 'JUMPSTART' },
    );

    has widget_builder_args => (
        is          => 'rw',
        isa         => HashRef,
        required    => 1,
        default     => sub { {} },
    );

    has layout_set_builder => (
        isa         => Object,
        required    => 1,
        lazy_build  => 1,
        handles     => { build_layout_set => 'JUMPSTART' },
    );

    has layout_set_builder_args => (
        is          => 'rw',
        isa         => HashRef,
        required    => 1,
        default     => sub { {} },
    );


    method JUMPSTART {

        $self->build_viewport;
        $self->build_widget;
        $self->build_layout_set;
    }

    method _build_viewport_builder {

        my $name = $self->view_group_name;

        return $self->new_sub_builder(ViewPort,
            additional => {
                viewport_namespace => $name,
                %{ $self->viewport_builder_args },
            },
        );
    }

    method _build_widget_builder {

        my $name = $self->view_group_name;

        return $self->new_sub_builder(Widget,
            additional => {
                widget_namespace => $name,
                %{ $self->widget_builder_args },
            },
        );
    }

    method _build_layout_set_builder {

        my $name = $self->view_group_name;

        return $self->new_sub_builder(LayoutSet,
            additional => {
                layout_set_name => Reaction::UI::View->layout_set_name_from_viewport("DUMMY::ViewPort::$name"),
                widget_name     => $name,
                %{ $self->layout_set_builder_args },
            },
        );
    }
}
