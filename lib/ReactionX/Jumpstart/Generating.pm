use MooseX::Declare;

role ReactionX::Jumpstart::Generating with ReactionX::Jumpstart::Stashing {

    use Class::Inspector;
    use Template;
    use File::ShareDir              qw( dist_dir );
    use MooseX::Types::Path::Class  qw( Dir );
    use Path::Class                 qw( dir );
    use Carp                        qw( croak );

    use signatures;
    

    requires qw( JUMPSTART );

    
    has root_path => (
        is          => 'ro',
        isa         => Dir,
        required    => 1,
        lazy        => 1,
        coerce      => 1,
        default     => sub ($self) {
            
            if (my $method = $self->can('find_root_path')) {
                return $self->$method;
            }

            croak "root_path attribute is required for ${\ref $self}";
        },
    );

    has _tt_engine => (
        is          => 'rw',
        isa         => 'Template',
        required    => 1,
        lazy_build  => 1,
        handles     => { _process_template => 'process' },
    );


    method _build__tt_engine {

        return Template->new(
            ABSOLUTE => 1,
            RELATIVE => 1,
        );
    }

    method find_share_file (Str $dist, $filename) {

        my $path = dir( $ENV{REACTIONX_JUMPSTART_SHAREDIR} || dist_dir $dist );
        my $file = $path->file($filename);

        croak "Shared file $file does not exist"
            unless -e $file;

        return $file;
    }

    method build_package (Str :$package!, Str :$template!, Str :$dist!, HashRef :$vars = {}) {

        my $package_filename  = $self->path_to_file('lib', Class::Inspector->filename($package)); 
        my $template_filename = $self->find_share_file($dist, "$template.tt");

        print " -> writing package $package\n";

        $self->_process_template("$template_filename", +{ %{ $self->stash }, %$vars }, "$package_filename");
    }

    method build_file (Str | Path::Class::File :$file!, Str :$template!, Str :$dist!, HashRef :$vars = {}) {

        my $template_filename = $self->find_share_file($dist, "$template.tt");

        print " -> writing file $file\n";

        $self->_process_template("$template_filename", +{ %{ $self->stash }, %$vars }, "$file");
    }

    method mkpath (@dir) { 

        my $dir = $self->path_to_dir(@dir);

        print " -> creating directory $dir\n";
        $dir->mkpath;

        return $dir;
    }

    method path_to_file (@file) { $self->root_path->file(@file) }

    method path_to_dir (@dir) { $self->root_path->subdir(@dir) }
}
