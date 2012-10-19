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

    # authorization process
    # ---------------------
    # PHASE 1: done by nginx, checking both user and password over https
    if (my $authorization = $self->req->headers->authorization) {
        my $username = (split ':' => Mojo::ByteStream->new(substr($authorization, 6))->b64_decode)[0];

        # PHASE 2: done by checking if the user is listed as admin in the app config
        my $config = $self->app->plugin('json_config');

        my $admins = $config->{'admins'};

        if ($username ~~ @$admins) {
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
#   my $giulia_route = $r->bridge('/giulia')
#           ->via('GET')
#           ->to('postcard#help');

    # postcard
    $r->route('/giulia/postcard/:id', id => qr/\d+/)
        ->via('GET')
        ->to('postcard#read');

    # POST PUT DELETE need authentication
    my $postcard_route_auth = $r->bridge('/giulia/postcard')
                                     ->via(qw(POST PUT DELETE))
                                     ->to(cb => $req_is_authorized);

    $postcard_route_auth->route('/')->via('POST')->to('postcard#create');
    $postcard_route_auth->route('/:id', id => qr/\d+/)->via('PUT')->to('postcard#update');
    $postcard_route_auth->route('/:id', id => qr/\d+/)->via('DELETE')->to('postcard#delete');

    # for any non-matched method (GET, PUT, DELETE) reply with the help
#    $giulia_route->route('/postcard')->to('postcard#help');

    # plugins
    $self->plugin('json_config');
}

1;
