package SabadelliDotIt::Giulia::DAO::Postcard;

use strict;
use warnings;

use DateTime ();
use Mojo::JSON ();
use Text::Markdown ();

use base 'SabadelliDotIt::Giulia::DAO::Base';

my $dao_base = 'SabadelliDotIt::Giulia::DAO::Base';

sub source {
    return 'postcards';
}

sub accessors {
    return qw(
        from_country
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

sub to_country {
    my $self = shift;

    my %code2name = (
        it => 'Italia',
        no => 'Norge',
        za => 'South Africa',
    );

    if (! $self->{data}->{to_country}) {
        $self->fetch();
    }

    if (my $country_code = $self->{data}->{to_country}) {
        return uc $code2name{$country_code};
    }

    return;
}

sub create {
    my ($self, $data) = @_;

    # set computed fields
    my $seo_title = lc $data->{title};

    $seo_title =~ s{\s+}{-}g;
    $seo_title =~ s{[^\w\-]}{}g;

    $data->{seo} = $seo_title;

    $data->{content} = Text::Markdown::markdown($data->{content_raw});

    $data->{pubdate} = time;

    return $self->SUPER::create($data);
}

#
# Class methods
#
# last postcard
sub get_last {
    my $type = shift;

    if (my $recent = $type->search_recent(1)) {
        return $recent->[0];
    }

    return;
}

# all postcards by yera
sub search_by_year {
    my ($type, $year) = @_;

    return $dao_base->search(
        {
            class =>$type,
            sql => q{SELECT id FROM postcards WHERE pubdate BETWEEN strftime('%s','?-01-01') AND strftime('%s','?-01-01','+1 year','-1 second') ORDER BY pubdate DESC},
            binds => [$year, $year],
        }
    );
}

# all postcards by month
sub search_by_month {
    my ($type, $year, $month) = @_;

    return $dao_base->search(
        {
            class =>$type,
            sql => q{SELECT id FROM postcards WHERE pubdate BETWEEN strftime('%s','?-?-01') AND strftime('%s','?-?-01','+1 month','-1 second') ORDER BY pubdate DESC},
            binds => [$year, $month, $year, $month],
        }
    );
}

# all postcards by day
sub search_by_day {
    my ($type, $year, $month, $day) = @_;

    return $dao_base->search(
        {
            class =>$type,
            sql => q{SELECT id FROM postcards WHERE pubdate BETWEEN strftime('%s', '?-?-?') AND strftime('%s', '?-?-?', '+1 day', '-1 second') ORDER BY pubdate DESC},
            binds => [$year, $month, $day, $year, $month, $day],
        }
    );
}

# single postcard by SEO title
sub search_by_seo {
    my ($type, $seo) = @_;

    my $records = $dao_base->search(
        {
            class => $type,
            sql => 'SELECT id FROM postcards WHERE seo = ?',
            binds => [$seo],
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

1;
