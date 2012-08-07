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

    $self->app->log->debug('POST data: ' . Data::Dumper::Dumper($self->req->params->to_hash));

    my $postcard = $dao_postcard->create($self->req->params->to_hash);

    if ($postcard && $postcard->content) {
# XXX        $self->add_to_feed($postcard);

        $self->render(json => {message => 'success'});
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
            $self->render(json => $postcard->{data});
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

    $self->app->log->debug('PUT data: ' . Data::Dumper::Dumper($self->req->json));

    my $postcard = $dao_postcard->new($self->stash('id'));

    if ($postcard && $postcard->update($self->req->json)) {
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
