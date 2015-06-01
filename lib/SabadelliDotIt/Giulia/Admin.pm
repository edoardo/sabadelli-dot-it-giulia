package SabadelliDotIt::Giulia::Admin;

use Net::OAuth ();
use Net::OAuth::ProtectedResourceRequest ();

use Mojo::Base 'Mojolicious::Controller';

use SabadelliDotIt::Giulia::DAO::Postcard;

my $dao_postcard = 'SabadelliDotIt::Giulia::DAO::Postcard';

# list published and draft postcards
# /giulia/admin
sub index {
    my $self = shift;

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

    my $params = $self->req->params->to_hash();

    # these need to be passed from the JavaScript, as we need to sign
    # 2 types of requests, upload and REST API
    my $request_url = delete($params->{request_url});
    my $request_method = delete($params->{request_method});

    my $request = Net::OAuth::ProtectedResourceRequest->new(
        # OAuth stuff
        consumer_key => $config->{flickr}->{key},
        consumer_secret => $config->{flickr}->{secret},
        token => $config->{flickr}->{access_token},
        token_secret => $config->{flickr}->{access_secret},
        timestamp => time,
        nonce => int(rand(2 ** 32)),
        signature_method => 'HMAC-SHA1',
        protocol_version => Net::OAuth::PROTOCOL_VERSION_1_0,
        request_method => $request_method,
        request_url => URI->new($request_url),
        extra_params => $params,
    );

    $request->sign();

    my $oauth_params = $request->to_hash;

    # Return OAuth parameters and original query parameters, plus the
    # OAuth signature.
    # All are used by JavaScript to make the actual API call
    # so signing is done server side, while API calls client side
    $self->render('json', {
        %$oauth_params,
# XXX these should be already included above
#        %$params,
    });
}

1;
