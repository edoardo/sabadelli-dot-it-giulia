package SabadelliDotIt::Giulia::API::Postcard;

use Mojo::Base 'Mojolicious::Controller';

use SabadelliDotIt::Giulia::DAO::Postcard;

my $dao_postcard = 'SabadelliDotIt::Giulia::DAO::Postcard';

sub help {
    my $self = shift;

    $self->render(json => {action => 'postcard help'});
}

sub create {
    my $self = shift;

    my $params = $self->req->params->to_hash();

    $self->app->log->debug('POST data: ' . Data::Dumper::Dumper($params));

    if (! %$params) {
        $self->render(
            json => {message => 'invalid parameters'},
            status => 411,
        );

        return;
    }

    my $postcard = $dao_postcard->create($params);

    if ($postcard && $postcard->content) {
# XXX        $self->add_to_feed($postcard);

        $self->render(json => {message => 'success', postcard => $postcard->{data}});
    }
    else {
        $self->render(
            json => {message => 'create postcard failed!'},
            status => 500,
        );
    }
}

sub delete {
    my $self = shift;

    my $postcard = $dao_postcard->new($self->stash('id'));

    if ($postcard && $postcard->delete()) {
        $self->render(json => {message => 'success'});
    }
    else {
        $self->render(
            json => {message => 'delete postcard failed!'},
            status => 500,
        );
    }
}

sub read {
    my $self = shift;

    my $postcard = $dao_postcard->new($self->stash('id'));

    if ($postcard && $postcard->content) {
        if (my $callback = $self->req->param('cb')) {
            my $data = $self->render(json => $postcard->{data}, partial => 1);

            $self->render(data => "$callback($data);", format => 'js');
        }
        else {
            my $json = $postcard->{data};
            $json->{media} = $postcard->media;
            $self->render(json => $json);
        }
    }
    else {
        $self->render(
            json => {message => 'postcard not found'},
            status => 400,
        );
    }
}

sub update {
    my $self = shift;

    my $params = $self->req->params->to_hash();

    $self->app->log->debug('PUT data: ' . Data::Dumper::Dumper($params));

    if (! %$params) {
        $self->render(
            json => {message => 'invalid parameters'},
            status => 411,
        );

        return;
    }

    my $postcard = $dao_postcard->new($self->stash('id'));

    if ($postcard && $postcard->update($params)) {
        $self->render(json => {message => 'success'});
    }
    else {
        $self->render(
            json => {message => 'update postcard failed!'},
            status => 500,
        );
    }
}

1;
