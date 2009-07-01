use MooseX::Declare;

role ReactionX::Jumpstart::Meta::Attribute::Trait::Prompted {

    use Carp          qw( croak );
    use Term::Prompt;


    has question => (
        is          => 'rw',
        required    => 1,
        predicate   => 'has_question',
    );

    has defaults_to => (
        is          => 'rw',
        required    => 0,
        predicate   => 'has_defaults_to',
    );

    has help_info => (
        is          => 'rw',
        required    => 0,
        predicate   => 'has_help_info',
    );


    around is_lazy { 1 }

    around has_default { 1 }

    around is_default_a_coderef { 1 }

    around default ($instance) { $self->prompt_for_value($instance) }

    around legal_options_for_inheritance { $self->$orig, qw( help_info defaults_to question ) }


    method _build_value_from_spec (Object $instance, Str $option, $default?) {

        return ''
            unless $self->${\"has_$option"};

        my $value = $self->$option;

        return $value
            unless ref $value;

        return $instance->$value($default)
            if ref $value eq 'CODE';

        return $instance->${\($value->[0])}($default, @{ $value }[1 .. $#$value])
            if ref $value eq 'ARRAY';

        croak "No idea what to do with $value $option specification for ${\ $self->name} on ${\ref $self}";
    }

    method build_question ($instance, $default) { $self->_build_value_from_spec($instance, 'question', $default) }

    method build_default_value ($instance) { $self->_build_value_from_spec($instance, 'defaults_to') }

    method build_help_info ($instance, $default) { $self->_build_value_from_spec($instance, 'help_info', $default) }

    method prompt_for_value ($instance) {

        if (my $builder = $instance->can('_build_' . $self->name)) {
            return $instance->$builder;
        }
        
        my $tc = $self->type_constraint
            or croak "Attribute ${\($self->name)} can't be prompted without a type constraint";

        my $try = $tc;
        my @tries;

        while ($try) {
            push @tries, ( my $name = $try->name );

            if (my $method = $self->can("prompt_for_${name}_value")) {

                local $Term::Prompt::MULTILINE_INDENT = '  ';

              VALUE:
                while (1) {

                    my $result = $self->$method($instance, $tc, $self->build_default_value($instance));
                    
                    if ($self->is_required and $result eq '') {
                        print "Value is required\n";
                        next VALUE;
                    }

                    return $result
                        if $tc->check($result);

                    printf "Invalid Input: %s\n", $tc->validate($result);
                }
            }

            $try = $try->parent;
        }

        croak "Unable to locate 'prompt_for_*_value' method for ${\ $self->name} on ${\ref $self}. Tried as *: "
            . join ', ', @tries;
    }

    method prompt_for_Str_value ($instance, $tc, $default) {
        prompt('x', 
            $self->build_question($instance, $default), 
            $self->build_help_info($instance, $default), 
            $default,
        );
    }

    method prompt_for_Bool_value ($instance, $tc, $default) {
        prompt('y',
            $self->build_question($instance, $default),
            $self->build_help_info($instance, $default),
            $default,
        );
    }
}
