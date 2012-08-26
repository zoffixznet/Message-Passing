package Message::Passing::Filter::Encoder::JSON;
use Moo;
use MooX::Types::MooseLike::Base qw/ Bool /;
use JSON qw/ to_json /;
use Scalar::Util qw/ blessed /;
use Try::Tiny;
use Data::Dumper ();
use namespace::clean -except => 'meta';

with qw/
    Message::Passing::Role::Filter
    Message::Passing::Role::HasErrorChain
/;

has pretty => (
    isa => Bool,
    default => sub { 0 },
    is => 'ro',
);

sub filter {
    my ($self, $message) = @_;
    try {
        return $message unless ref($message);
        if (blessed $message) { # FIXME - This should be moved out of here!
            if ($message->can('pack')) {
                $message = $message->pack;
            }
            elsif ($message->can('to_hash')) {
                $message = $message->to_hash;
            }
        }
        to_json( $message, { utf8  => 1, $self->pretty ? (pretty => 1) : () } )
    }
    catch {
        $self->error->consume({
            class => 'Message::Passing::Exception::Encoding',
            exception => $_,
            stringified_data => Data::Dumper::Dumper($message),
        });
        return; # Explicitly drop the message from normal processing
    }
}

1;

=head1 NAME

Message::Passing::Role::Filter::Encoder::JSON - Encodes data structures as JSON for output

=head1 DESCRIPTION

This filter takes a hash ref or an object for a message, and serializes it to JSON.

Plain refs work as expected, and classes generated by either:

=over

=item Log::Message::Structures

=item MooseX::Storage

=back

should be correctly serialized.

=head1 METHODS

=head2 filter

Performs the JSON encoding.

=head2 pretty

Attribute controlling if JSON is pretty printed.

=head1 SEE ALSO

=over

=item L<Message::Passing>

=item L<Message::Passing::Manual::Concepts>

=back

=head1 SPONSORSHIP

This module exists due to the wonderful people at Suretec Systems Ltd.
<http://www.suretecsystems.com/> who sponsored its development for its
VoIP division called SureVoIP <http://www.surevoip.co.uk/> for use with
the SureVoIP API - 
<http://www.surevoip.co.uk/support/wiki/api_documentation>

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Message::Passing>.

=cut

