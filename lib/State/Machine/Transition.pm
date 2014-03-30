# ABSTRACT: State Machine State Transition Class
package State::Machine::Transition;

use Bubblegum::Class;
use State::Machine::Failure;
use State::Machine::State;
use Try::Tiny;

use Bubblegum::Constraints -minimal;

our $VERSION = '0.03'; # VERSION

has 'name' => (
    is       => 'ro',
    isa      => _string,
    required => 1
);

has 'result' => (
    is       => 'rw',
    isa      => _object,
    required => 1
);

has 'hooks' => (
    is      => 'ro',
    isa     => _hashref,
    default => sub {{
        before => [],
        during => [],
        after  => []
    }}
);

has 'executable' => (
    is      => 'rw',
    isa     => _integer,
    default => 1
);

has 'terminated' => (
    is      => 'rw',
    isa     => _integer,
    default => 0
);

sub execute {
    my $self = _object shift;
    return if !$self->executable;

    my @schedules = (
        $self->hooks->get('before'),
        $self->hooks->get('during'),
        $self->hooks->get('after'),
    );

    $self->terminated(0);
    for my $schedule (@schedules) {
        if (isa_arrayref $schedule) {
            for my $task ($schedule->list) {
                next if $self->terminated or !$task->typeof('code');
                $task->call($self, @_);
            }
        }
    }

    return $self->result;
}

sub hook {
    my $self = _object shift;
    my $name = _string shift;
    my $code = _coderef shift;
    my $list = $self->hooks->get($name);

    unless ($list->typeof('array')) {
        # transition add-hook failure
        State::Machine::Failure->raise(
            class      => 'transition/hook',
            message    => "Unrecognized hook ($name) in transition.",
            transition => $self,
            hook       => $name,
        );
    }

    $list->push($code);
    return $self;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

State::Machine::Transition - State Machine State Transition Class

=head1 VERSION

version 0.03

=head1 SYNOPSIS

    use State::Machine::Transition;

    my $trans = State::Machine::Transition->new(
        name   => 'resume',
        result => State::Machine::State->new(name => 'awake')
    );

    $trans->hook(during => sub {
        # do something during resume
    });

=head1 DESCRIPTION

State::Machine::Transition represents a state transition and it's resulting
state.

=head1 ATTRIBUTES

=head2 executable

    my $executable = $trans->executable;
    $trans->executable(1);

The executable flag determines whether a transition can be execute.

=head2 hooks

    my $hooks = $trans->hooks;

The hooks attribute contains the collection of triggers and events to be fired
when the transition is executed. The C<hook> method should be used to configure
any hooks into the transition processing.

=head2 name

    my $name = $trans->name;
    $name = $trans->name('suicide');

The name of the transition. The value can be any scalar value.

=head2 result

    my $state = $trans->result;
    $state = $trans->result(State::Machine::State->new(...));

The result represents the resulting state of a transition. The value must be a
L<State::Machine::State> object.

=head2 terminated

    my $terminated = $trans->terminated;
    $trans->terminated(1);

The terminated flag determines whether a transition in-execution should
continue (i.e. processing hooks). This flag is reset on each execution an is
meant to be called from within a hook.

=head1 METHODS

=head2 hook

    $trans = $trans->hook(during => sub {...});
    $trans->hook(before => sub {...});
    $trans->hook(after => sub {...});

The hook method registers a new hook in the append-only hooks collection to be
fired when the transition is executed. The method requires an event name,
either C<before>, C<during>, or C<after>, and a code reference.

=encoding utf8

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
