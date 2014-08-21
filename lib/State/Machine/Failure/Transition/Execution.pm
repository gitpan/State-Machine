# State::Machine::Transition Execution Failure Class
package State::Machine::Failure::Transition::Execution;

use Bubblegum::Class;
use Function::Parameters;

extends 'State::Machine::Failure::Transition';

our $VERSION = '0.06'; # VERSION

method _build_message {
    "Transition execution failure."
}

1;
