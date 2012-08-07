package SabadelliDotIt::Giulia::Postcards;

use Mojo::Base 'Mojolicious::Controller';

use SabadelliDotIt::Giulia::DAO::Postcard;

my $dao_postcard = 'SabadelliDotIt::Giulia::DAO::Postcard';

# last postcard
# /giulia
sub index {
    my $self = shift;

    $self->stash->{template} = 'postcard';

    $self->stash->{postcard} = $dao_postcard->get_last();
}

# show a single postcard
# /giulia/2012/07/17/seo-title
sub read_postcard {
    my $self = shift;

    $self->stash->{template} = 'postcard';

    $self->stash->{postcard} = $dao_postcard->search_by_seo($self->stash('seo'));
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
# /edoardo/blog/feed
# XXX probably serve it statically
sub feed {
    my $self = shift;

    require XML::Atom::Feed;
    require XML::Atom::Entry;

    $self->render(atom => 'TODO Atom feed');
}

1;
