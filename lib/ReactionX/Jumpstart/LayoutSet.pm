use MooseX::Declare;

class ReactionX::Jumpstart::LayoutSet
    with ReactionX::Jumpstart::Generating
    with ReactionX::Jumpstart::Stashing
    with ReactionX::Jumpstart::SubBuilding
    with ReactionX::Jumpstart::Namespacing {

    use MooseX::Types::Moose qw( Str Bool );

    use Reaction::UI::View;


    has layout_set_name => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => 'Name of the LayoutSet?',
    );

    has layout_set_is_extension => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Bool,
        question    => "Is this LayoutSet an extension of another one?",
        defaults_to => 0,
    );

    has base_layout_set_name => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => "Name of the parent LayoutSet?",
    );

    has widget_name_is_explicit => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Bool,
        question    => "Does the LayoutSet require an explicit Widget?",
        defaults_to => 0,
    );

    has widget_name => (
        traits      => [qw( ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted )],
        is          => 'rw',
        isa         => Str,
        question    => "Name of the LayoutSet's explicit Widget?",
        defaults_to => sub {
            my ($self) = @_;

            my $widget = join('',   map { ucfirst($_) } split('_', $self->layout_set_name));
            $widget    = join('::', map { ucfirst($_) } split('/', $widget));

            return $widget;
        },
    );


    method JUMPSTART {

        my $lset      = $self->layout_set_name;
        my $lset_file = $self->path_to_file('share/skin', $self->stash->{skin_name}, 'layout', "$lset.tt");

        my %args = (layout_set => $lset);

        if ($self->layout_set_is_extension) {
            $args{layout_set_base} = $self->base_layout_set_name;
        }

        if ($self->widget_name_is_explicit) {
            $args{widget_name} = $self->widget_name;
        }

        $self->build_file(
            file        => $lset_file,
            dist        => 'ReactionX-Jumpstart',
            template    => 'layout_set',
            vars        => \%args,
        );
    }
}
