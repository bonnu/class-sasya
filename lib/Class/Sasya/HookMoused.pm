package Class::Sasya::HookMoused;

use Mouse;
extends qw/Tree::Simple/;
use MouseX::AttributeHelpers;

use Carp ();
use Storable ();
use Tree::Simple qw/use_weak_refs/;
use UNIVERSAL::require;

use Class::Sasya::Callback;

sub BREAK    () { 0 }
sub CONTINUE () { 1 }

has callback => (
    is      => 'ro',
    isa     => 'Class::Sasya::Callback',
    lazy    => 1,
    default => sub { Class::Sasya::Callback->new },
    handles => { register => 'add' },
);

has hold_stack => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] },
);

sub hook {
    my ($id, $type, %args) = @_;
    my $class = __PACKAGE__;
    if ($type) {
        $class .= "::$type";
        $class->require or Carp::confess $@;
    }
    return $class->new(id => $id, %args);
}

sub BUILD {
    my ($self, $args) = @_;
    my ($id, $parent, $holder) = @{$args}{qw/id parent holder/};
    if ($parent) {
        $parent->is_unique_on_fraternity($id)
            || Carp::croak "is not unique on fraternity : $id";
    }
    unless ($id) {
        $parent && Carp::croak 'id is necessary for the child.';
        $id = '/';
    }
    $self->Tree::Simple::_init({}, $parent, []);
    $self->setUID($id);
    $self->update_hold_stack($holder) if $holder;
}

sub update_hold_stack {
    my ($self, $holder) = @_;
    my $hold_stack = $self->hold_stack;
    for my $i ($#{ $hold_stack } .. -1) {
        last if $i < 0;
        splice @{ $hold_stack }, $i, 1 if $hold_stack->[$i] eq $holder;
    }
    unshift @{ $hold_stack }, $holder;
}

sub is_unique_on_fraternity {
    my ($self, $id) = @_;
    return unless defined $id && length $id;
    map { return if $_->{_uid} eq $id } @{ $self->{_children} };
    return 1;
}

sub _is_hook {
    my $id  = shift || return;
    my $ref = ref $id || return;
    return if $ref =~ /^(ARRAY|CODE|GLOB|HASH|REF|Regexp|SCALAR)$/;
    return $id->isa(__PACKAGE__);
}

sub append_hooks {
    my ($self, $args, @hooks) = @_;
    my $level  = exists $args->{level} ? delete $args->{level} : 0;
    my $caller = caller $level;
    while (my $id = shift @hooks) {
        my $hook;
        if (_is_hook($id)) {
            $self->addChild($hook = $id);
        }
        else {
            $hook = hook($id => undef, parent => $self);
        }
        $hook->update_hold_stack($caller);
        if (0 < @hooks && ref $hooks[0] eq 'ARRAY') {
            $hook->append_hooks(
                { %{ $args }, level => $level + 1 }, @{ shift @hooks },
            );
        }
    }
}

sub invoke {
    my ($self, $root, @args) = @_;
    my $callback = $self->{callback} || $self->callback;
    while (my $sub = $callback->iterate) {
        my $ret = ref $sub ? $sub->($root, @args) : $root->$sub(@args);
        unless ($ret) {
            $callback->reset;
            last;
        }
    }
}

sub traverse {
    my ($self, $context, $func) = @_;
    $context->current($self);
    $func->($self);
    return BREAK if $context->goto || $context->return;
    map {
        return BREAK unless $_->traverse($context, $func)
    } @{ $self->{_children} };
    return CONTINUE;
}

sub get_path {
    my $self = shift;
    my $cur  = $self;
    my @path;
    until ($cur->isRoot) {
        unshift @path, $cur->{_uid};
        $cur = $cur->{_parent};
    }
    return '/' . join '/', @path;
}

sub get_root {
    my $self = shift;
    return $self if $self->isRoot;
    return $self->getParent->get_root;
}

sub find_by_path {
    my $self = shift;
    my @path = @_ == 1 ? split m{(?:(?<=^/)|(?<!^)/)}, $_[0] : @_;
    my $cur  = $self;
    if (0 < @path && $path[0] eq '/') {
        shift @path;
        $cur = $self->get_root;
    }
    if (0 < @path) {
        my $id = shift @path;
        for my $child ($cur->getAllChildren) {
            return $child->find_by_path(@path) if $child->{_uid} eq $id;
        }
        undef $cur;
    }
    return $cur ? $cur : ();
}

sub clone {
    my $self = shift;
    return Storable::dclone($self);
}

no Mouse;

__PACKAGE__->meta->make_immutable(inline_destructor => 1);

1;

__END__
