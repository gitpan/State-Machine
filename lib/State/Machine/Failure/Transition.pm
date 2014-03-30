# State::Machine Transition Failure Class
package State::Machine::Failure::Transition;

use Bubblegum::Class;
use Bubblegum::Constraints -minimal;

extends 'State::Machine::Failure';

our $VERSION = '0.03'; # VERSION

has transition => (
    is       => 'ro',
    isa      => _object,
    required => 1
);

1;
