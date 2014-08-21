# State::Machine Failure Class
package State::Machine::Failure;

use Bubblegum::Class;
use Function::Parameters;

use Bubblegum::Constraints 'typeof_string';

extends 'Throwable::Error';

our $VERSION = '0.05'; # VERSION

has 'message' => (
    is      => 'ro',
    isa     => typeof_string,
    lazy    => 1,
    builder => '_build_message',
);

method _build_message {
    "An unexpected failure has occurred"
}

1;
