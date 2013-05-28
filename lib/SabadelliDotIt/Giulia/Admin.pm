package SabadelliDotIt::Giulia::Admin;

use Mojo::Util ();

use Mojo::Base 'Mojolicious::Controller';

use SabadelliDotIt::Giulia::DAO::Postcard;

my $dao_postcard = 'SabadelliDotIt::Giulia::DAO::Postcard';

# list published and draft postcards
# /giulia/admin
sub index {
    my $self = shift;

    $self->stash->{env} = {
        api_host => 'https://' . $self->stash->{config}->{api_host},
        static_host => 'https://' . $self->stash->{config}->{static_host},
    };

    $self->stash->{js_config} = $self->render(
        partial => 1,
        json => $self->stash('config')->{'js_config'},
    );

#   $self->stash->{content} = {
#       postcard => $dao_postcard->get_last(),
#   };
}

sub edit_postcard {
    my $self = shift;

    $self->stash->{env} = {
        static_host => 'https://' . $self->stash->{config}->{static_host},
    };

    my $postcard = $dao_postcard->new($self->stash('id'));
    $self->stash->{postcard} = $postcard;

    $self->stash->{js_config} = $self->render(
        partial => 1,
        json => $self->stash('config')->{'js_config'},
    );

    $self->stash->{template} = 'admin/index';
}

sub sign_flickr_request {
    my $self = shift;

    my $config = $self->stash('config');
    my $secret = $config->{flickr}->{secret};

    my $params = $self->req->params->to_hash();

    $params->{auth_token} = $config->{flickr}->{auth_token};
    $params->{api_key} = $config->{flickr}->{key};

    my $string = $secret . join('', map {$_ => $params->{$_}} sort {$a cmp $b} keys %$params);

    # XXX return all parameters with the missing ones (ie. api_key) and the signature
    # JSON response, used by JavaScript to make the actual API call
    # so signing is done server side, while API calls client side
    $self->render('json', {
        api_key => $config->{flickr}->{key},
        auth_token => $params->{auth_token},
        api_sig => Mojo::Util::md5_sum($string)
    });
}

1;
