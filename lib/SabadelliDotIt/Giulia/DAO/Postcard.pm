package SabadelliDotIt::Giulia::DAO::Postcard;

use strict;
use warnings;

use DateTime ();
use Mojo::JSON ();
use Text::Markdown ();

use base 'SabadelliDotIt::DAO::Base';

my $dao_base = 'SabadelliDotIt::DAO::Base';
$dao_base->dbname('db/postcards.sqlite');


sub source {
    return 'postcards';
}

sub accessors {
    return qw(
        from_country
        to_country
        recipients
        title seo
        content content_raw
        pubdate
        lang
        is_draft
    );
}

#
# Instance methods
#

# the postcard sent right after the current one
sub get_next {
    my $self = shift;

    if (! $self->{data}->{pubdate}) {
        $self->fetch();
    }

    return __PACKAGE__->search_after_date($self->{data}->{pubdate});
}


# the postcard sent right before the current one
sub get_previous {
    my $self = shift;

    if (! $self->{data}->{pubdate}) {
        $self->fetch();
    }

    return __PACKAGE__->search_before_date($self->{data}->{pubdate});
}


# parse the JSON stored in the media field and return a hash instead
sub media {
    my $self = shift;

    if (! $self->{data}->{media}) {
        $self->fetch();
    }

    if ($self->{data}->{media}) {
        return Mojo::JSON->new->decode($self->{data}->{media});
    }

    return;
}


# return the plain string as stored in the db
sub media_raw {
    my $self = shift;

    if (! $self->{data}->{media}) {
        $self->fetch();
    }

    return $self->{data}->{media};
}

sub permalink {
    my $self = shift;

    if (! $self->{data}->{seo}) {
        $self->fetch();
    }

    my $pubdate = DateTime->from_epoch(epoch => $self->{data}->{pubdate});

    return join(
        '/',
        $pubdate->ymd('/'),
        $self->{data}->{seo},
    );
}

sub update {
    my ($self, $data) = @_;

    $data = _prepare_data($data);

    return $self->SUPER::update($data);
}


#
# Class methods
#

sub create {
    my ($type, $data) = @_;

    $data = _prepare_data($data);

    $data->{pubdate} = time;

    return $type->SUPER::create($data);
}


# last postcard
sub get_last {
    my $type = shift;

    if (my $recent = $type->search_recent(1)) {
        return $recent->[0];
    }

    return;
}

# all postcards by year
sub search_by_year {
    my ($type, $year) = @_;

    my $date = "$year-01-01";

    return $dao_base->search(
        {
            class => $type,
            sql => q{SELECT id FROM postcards WHERE pubdate BETWEEN strftime('%s', ?) AND strftime('%s', ?, '+1 year', '-1 second') ORDER BY pubdate ASC},
            binds => [$date, $date],
        }
    );
}

# all postcards by month
sub search_by_month {
    my ($type, $year, $month) = @_;

    my $date = "$year-$month-01";

    return $dao_base->search(
        {
            class => $type,
            sql => q{SELECT id FROM postcards WHERE pubdate BETWEEN strftime('%s', ?) AND strftime('%s', ?, '+1 month', '-1 second') ORDER BY pubdate ASC},
            binds => [$date, $date],
        }
    );
}

# all postcards by day
sub search_by_day {
    my ($type, $year, $month, $day) = @_;

    my $date = "$year-$month-$day";

    return $dao_base->search(
        {
            class => $type,
            sql => q{SELECT id FROM postcards WHERE pubdate BETWEEN strftime('%s', ?) AND strftime('%s', ?, '+1 day', '-1 second') ORDER BY pubdate ASC},
            binds => [$date, $date],
        }
    );
}

# single postcard by date and SEO title
sub search_by_date_seo {
    my ($type, $year, $month, $day, $seo) = @_;

    my $date = "$year-$month-$day";

    my $records = $dao_base->search(
        {
            class => $type,
            sql => q{SELECT id FROM postcards WHERE pubdate BETWEEN strftime('%s', ?) AND strftime('%s', ?, '+1 day', '-1 second') AND seo = ?},
            binds => [$date, $date, $seo],
        }
    );

    if ($records) {
        return $records->[0];
    }

    return;
}

# before date
sub search_before_date {
    my ($type, $epoch) = @_;

    my $records = $dao_base->search(
        {
            class => $type,
            sql => 'SELECT id FROM postcards WHERE is_draft = ? AND pubdate < ? ORDER BY pubdate DESC LIMIT 1',
            binds => [0, $epoch],
        }
    );

    if ($records) {
        return $records->[0];
    }

    return;
}

sub search_after_date {
    my ($type, $epoch) = @_;

    my $records = $dao_base->search(
        {
            class => $type,
            sql => 'SELECT id FROM postcards WHERE is_draft = ? AND pubdate > ? ORDER BY pubdate ASC LIMIT 1',
            binds => [0, $epoch],
        }
    );

    if ($records) {
        return $records->[0];
    }

    return;
}

# all drafts
sub search_drafts {
    my ($type, $limit) = @_;

    return $dao_base->search(
        {
            class => $type,
            sql => 'SELECT id FROM postcards WHERE is_draft = ? ORDER BY pubdate DESC',
            binds => [1],
            limit => $limit,
        }
    );
}

# all posted
sub search_posted {
    my ($type, $limit) = @_;

    return $dao_base->search(
        {
            class => $type,
            sql => 'SELECT id FROM postcards WHERE is_draft = ? ORDER BY pubdate DESC',
            binds => [0],
            limit => $limit,
        }
    );
}

# recent postcards
sub search_recent {
    my ($type, $limit) = @_;

    return $dao_base->search(
        {
            class => $type,
            sql => 'SELECT id FROM postcards WHERE is_draft = ? ORDER BY pubdate DESC LIMIT ?',
            binds => [0, $limit || 1],
        }
    );
}

#
# Private methods
#

sub _prepare_data {
    my $data = shift;

    # set computed fields
    my $seo_title = lc $data->{title};

    $seo_title =~ s{\s+}{-}g;
    $seo_title =~ s{[^\w\-]}{}g;

    $data->{seo} = $seo_title;

    $data->{content} = Text::Markdown::markdown($data->{content_raw});

    return $data;
}

1;
