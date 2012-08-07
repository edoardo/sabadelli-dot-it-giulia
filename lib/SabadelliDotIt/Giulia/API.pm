package SabadelliDotIt::Giulia::API;

# REST API for the postcards
# - http://api.sabadelli.it/giulia
# - https://api.sabadelli.it/giulia
#
# GET requests made by visitors are served via http
# PUT, DELETE, and POST requests made by admins are served via https with authentication

use Mojo::Base 'Mojolicious';

my $req_is_authorized = sub {
    my $self = shift;

    if (my $authorization = $self->req->headers->authorization) {
        my $username = (split ':' => Mojo::ByteStream->new(substr($authorization, 6))->b64_decode)[0];

        # TODO
        # verify authorization
        # nginx sufficient ?!
        # https and http for api, specific redirects to http for URLs requiring authentication

        if ($username eq 'giulia') { # XXX
            return 1;
        }

        $self->render(
            json => {message => 'Invalid credentials'},
            status => 401,
        );

        return 0;
    }
    else {
        $self->render(
            json => {message => 'Authorization required!'},
            status => 401,
        );

        return 0;
    }
};

sub startup {
    my $self = shift;

    my $r = $self->routes;

    # /giulia
    my $giulia_route = $r->waypoint('/giulia')
            ->via('GET')
            ->to('postcard#help');

    # postcard
    $giulia_route->route('/postcard/:id', id => qr/\d+/)
            ->via('GET')
            ->to('postcard#read');
# XXX
    $r->route('/giulia/postcard')->via('POST')->to('postcard#create');

#   # POST PUT DELETE need authentication
#   my $postcard_route_auth = $r->bridge('/giulia/postcard')
#                                    ->via(qw(POST PUT DELETE))
#                                    ->to(cb => $req_is_authorized);

#   $postcard_route_auth->route('/')->via('POST')->to('postcard#create');
#   $postcard_route_auth->route('/:id', id => qr/\d+/)->via('PUT')->to('postcard#update');
#   $postcard_route_auth->route('/:id', id => qr/\d+/)->via('DELETE')->to('postcard#delete');

    # for any non-matched method (GET, PUT, DELETE) reply with the help
#    $giulia_route->route('/postcard')->to('postcard#help');
}

1;
