package WebService::ViewText;

use warnings;
use strict;
use LWP::UserAgent;
use Carp qw/croak carp/;
use HTTP::Status ':constants';
use JSON;
use WebService::ViewText::Response;

=head1 NAME

WebService::ViewText - Perl Interface to L<ViewText.org|http:/www.viewtext.org>

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

our @res_headers = qw/
    X-Error
/;

=head1 SYNOPSIS

    use WebService::ViewText;

    my $ril = WebService::ViewText->new(
    );
    my $ret = $ril->text('http://www.google.com');

=head1 SUBROUTINES/METHODS

=head2 new

    my $ril = WebService::ViewText->new(
        ua     => $ua_config
        cache  => $cache,
    );

Constructs B<WebService::ViewText> object.
It takes hash, which keys are B<cache>, and B<ua>.

B<ua> is passed directly to L<LWP::UserAgent> constructor.  

The response against B<text> method is cached to B<cache> if specified, although the cache functionality hasn't implemented yet.

=cut

sub new {
    my ($class, %args) = @_;

    my ($cache, $ua, $debug)
        = map { delete $args{$_} } qw/cache ua debug/;
    $ua ||= {};

    my $self = bless {
        debug    => $debug,
        ua       => LWP::UserAgent->new(%$ua),
        $cache? ( cache => $cache ) : (),
        basic_params => {
        },
        base_url => 'http://viewtext.org/api/',
    }, $class;

    $self;
}

=head1 APIs

Methods this module provides basically has one-to-one ralationship to the API
ViewText provides.  So the description to the methods is derived from its
L<documentation pages|http://viewtext.org/help/api>.

=head2 text

    my $data = $ril->text(
        url => 'http://www.google.com',
        format => 'html',
        callback => '',
        rl => true,
        mld=0.8,
    );


This method allows you to retrieve a text view of the url.

You can specify some options like above.  Complete options are listed on
<here|http://viewtext.org/help/api/>

=cut

sub text {
    my ($self, %opt) = @_;

    $opt{format} = 'json' unless exists $opt{format};
    $opt{rl} = 'false' unless exists $opt{rl};
    my ($ok, $res) = $self->_request( 'text' => {
        %opt
    });

	return undef unless $ok;
    my $ret = WebService::ViewText::Response::Item->new(
        decode_json $res->content
    );
    $ret;
}

sub _format_tags {
    my ($self, @items) = @_;

    my $req = {};
    my $cnt = 0;

    while ( my ($url, $tags) = splice @items, 0, 2 ) {
        $req->{$cnt++} = {
            url  => "$url",
            tags => join ',' => @$tags
        };
    }
    $req;
}

sub _format_read {
    my ($self, @items) = @_;

    my $req = {};
    my $cnt = 0;

    foreach my $item (@items) {
        if ( ref $item && $item->isa('WebService::ViewText::Response::Item') ) {
            $req->{$cnt} = { url => $item->url->as_string };
        }
        else {
            $req->{$cnt} = { url => "$item" };
        }
        $cnt++;
    }
    $req;
}

sub _format {
    my ($self, @pages) = @_;

    my $req = {};
    my $cnt = 0;

    while( my ($url, $title) = splice @pages, 0, 2 ) {
        Carp::croak "url is missing"   unless $url;
        Carp::croak "title is missing" unless $title;

        $req->{$cnt}->{url}   = "$url";
        $req->{$cnt}->{title} = $title;
        $cnt++;
    }

    $req;
}

sub _request {
    my ($self, $extra_path, $opt) = @_;

    my $url = $self->{base_url} . $extra_path;
    my $res = $self->{ua}->post( $url => {
        $opt? %$opt : (),
    });

	if ($res->is_error) {
		# we got an error, either 4xx or 5xx, should handle, and return
        Carp::carp "[", $res->code, "] ", $res->message, "\n";
	}

    ($res->code == HTTP_OK, $res);
}

sub _save_response_header {
    my ($self, $res) = @_;

    foreach my $header (@res_headers) {
        my $key = $header;
        my $val = $res->header($key);

        $key =~ s/^X-//;
        $key =~ s/^Limit-//;
        $key =  lc $key;
        $key =~ tr/-/_/;        # convert hyphen to underbar

        $self->{res}->{$key} = $val;
    }
}

=head2 error

Detailed description of the error. Also in the case of a 503 status (when ViewText is undergoing maintenance, this will provide information to display to the user. Ex: 'Read It Later is upgrading its servers and will return in 30 minutes')

=cut

sub error          { $_[0]->{res}->{error} }

=head1 AUTHOR

Nikola Knezevic, C<< <laladelausanne at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<github|https://github.com/knl/WebService-ViewText>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::ViewText

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Nikola Knezevic.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WebService::ViewText
