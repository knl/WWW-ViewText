package WWW::ViewText::Response;

use warnings;
use strict;
use base qw/Class::Accessor::Fast/;
use URI;

sub new {
    my ($class, $h) = @_;

    my $self = bless {}, $class;
    for my $ac ( $class->accessors() ) {
        if ( ($ac eq 'url' or $ac eq 'responseUrl') && $h->{$ac} ) {
            $self->$ac( URI->new($h->{$ac}) );
        } else {
            $self->$ac( $h->{$ac} );
        }
    }
    $self;
};

# ================================================================================
package WWW::ViewText::Response::Item;

use base qw/WWW::ViewText::Response/;
sub accessors {
    qw/url title responseUrl content/
}
__PACKAGE__->mk_accessors( accessors() );

1;
