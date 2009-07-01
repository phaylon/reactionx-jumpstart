use MooseX::Declare;

role ReactionX::Jumpstart::SubBuilding {

    use List::MoreUtils qw( uniq );

    method new_sub_builder (Str $class, ArrayRef[Str] :$passthrough = [], HashRef :$additional = {}) {
        return $class->new(
            (   map  { ($_ => $self->$_) } 
                grep { $self->can($_) }
                uniq @$passthrough, 
                     qw( root_path ui_namespace project_namespace stash ),
            ),
            %$additional,
        );
    }
}
