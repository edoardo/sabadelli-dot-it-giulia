package SabadelliDotIt::Giulia::Postcards;

use Mojo::Base 'Mojolicious::Controller';

use SabadelliDotIt::Giulia::DAO::Postcard;

my $dao_postcard = 'SabadelliDotIt::Giulia::DAO::Postcard';

# last postcard
# /giulia
sub index {
    my $self = shift;

    $self->stash->{template} = 'postcard';

    my $last_postcard = $dao_postcard->get_last();
    my $prev_postcard = $last_postcard->get_previous();
    my $next_postcard = $last_postcard->get_next();

    $self->stash->{postcard} = $last_postcard;
    $self->stash->{nav} = {
        prev => ($prev_postcard and $prev_postcard->permalink()),
        next => ($next_postcard and $next_postcard->permalink()),
    };
}

# show a single postcard
# /giulia/2012/07/17/seo-title
sub read_postcard {
    my $self = shift;

    $self->stash->{template} = 'postcard';

    my $postcard = $dao_postcard->search_by_seo($self->stash('seo'));
    my $prev_postcard = $postcard->get_previous();
    my $next_postcard = $postcard->get_next();

    $self->stash->{postcard} = $postcard;
    $self->stash->{nav} = {
        prev => ($prev_postcard and $prev_postcard->permalink()),
        next => ($next_postcard and $next_postcard->permalink()),
    };
}

# postcards of the given year
# /giulia/2012
sub search_by_year {
    my $self = shift;

    $self->stash->{content} = {
        postcards => $dao_postcard->search_by_year($self->stash('year')),
    };
}

# postcards of the given month
# /giulia/2012/07
sub search_by_month {
    my $self = shift;

    $self->stash->{content} = {
        postcards => $dao_postcard->search_by_month($self->stash('year'), $self->stash('month')),
    };
}

# /giulia/2012/07/17
sub search_by_day {
    my $self = shift;

    $self->stash->{content} = {
        postcards => $dao_postcard->search_by_day($self->stash('year'), $self->stash('month'), $self->stash('day')),
    };
}

# Atom feed
# /giulia/feed
# XXX probably serve it statically
sub feed {
    my $self = shift;

    $self->stash->{template} = 'feed';

    # get last 10 postcards
    my $postcards = $dao_postcard->search_posted(2);
    $self->stash->{postcards} = $postcards;
    $self->stash->{feed} = {last_update => $postcards->[0]->pubdate};

    $self->render(format => 'atom');
}

1;
