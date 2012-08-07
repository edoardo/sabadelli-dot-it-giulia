package SabadelliDotIt::Giulia::DAO::Base;

use strict;
use warnings;

use Data::Dumper ();
use DBI ();
use Mojo::Date ();

sub new {
    my $proto = shift;

    my $class = ref $proto || $proto || __PACKAGE__;

    my $self = {
        id => undef,
        data => {},
    };

    if (@_) {
        $self->{id} = shift;
    }

    bless $self, $class;

    $self->_install_accessors();

    return $self;
}

{
    my $dbh;

    sub dbh {
        $dbh //= DBI->connect(
            'dbi:SQLite:dbname=db/postcards.sqlite',
            '', '',
            {
                RaiseError => 1,
                PrintError => 1,
                sqlite_unicode => 1,
            }
        );

        return $dbh;
    }
}

sub create {
    my ($type, $data) = @_;

    my $dbh = dbh();
    my $source = $type->source();

# XXX check for race condition
# user fiddling with the api and not passing the id for
# a record with an email that already exists
# the id in that case changes, breaking the references in the other tables
    my $sql = sprintf(
            'INSERT OR REPLACE INTO %s (%s) VALUES (%s)',
            $source,
            join(',' => keys %$data),
            join(',' => ('?') x scalar values %$data)
        );
warn 'create sql: ' . $sql . "\n";
    my $sth = $dbh->do(
        sprintf(
            'INSERT OR REPLACE INTO %s (%s) VALUES (%s)',
            $source,
            join(',' => keys %$data),
            join(',' => ('?') x scalar values %$data)
        ),
        undef,
        values %$data
    );
warn 'create error ' . $dbh->err . $dbh->errstr . $sql . "\n";
    return $type->new($dbh->last_insert_id(undef, undef, $source, undef));
}

sub source {
    my $self = shift;

    Carp::cluck("Not implemented for $self");

    return;
}

sub delete {
    my $self = shift;

    return if ! $self->id;

    my $source = $self->source();

    return $self->dbh->do("DELETE FROM $source WHERE id = ?", undef, $self->id);
}

sub fetch {
    my ($self, $fields) = @_;
warn 'fetch called! ' . caller(1);
    return if ! $self->id; # XXX

    my $source = $self->source();
    $fields ||= '*';

    my $sth = $self->dbh->prepare("SELECT $fields FROM $source WHERE id = ?");
    $sth->execute($self->id);

    my $row = $sth->fetchrow_hashref();

    if ($row && $row->{id}) {
warn 'data: ' . Data::Dumper::Dumper($row);
        $self->{data} = $row;
    }

    return $self->{data};
}

sub update {
    my ($self, $data) = @_;

    return if ! $self->id;

    my $source = $self->source();
    my $fields = join ', ' => map { "$_ = ?" } keys %$data;

    my $sth = $self->dbh->prepare("UPDATE $source SET $fields WHERE id = ?");
    $sth->execute(values %$data, $self->id);

    return 1; # XXX
}

sub id {
    return shift->{id};
}

sub search {
    my ($self, $args) = @_;
warn 'sql: ' . $args->{sql} . ' - binds: ' . "@{$args->{binds}}";
    my $sth = dbh->prepare($args->{sql});
    $sth->execute(@{$args->{binds}});

    my $rows = $sth->fetchall_arrayref({});

    my @records;

    my $limit = $args->{limit};

    if (scalar @$rows) {
        if ($limit) {
            splice(@$rows, $limit);
        }

        foreach my $row (@$rows) {
            push @records, $args->{class}->new($row->{id});
        }
    }

    return \@records;
}

sub _install_accessors {
    my $self = shift;

    if (! $self->can('accessors')) {
        return;
    }

    foreach my $accessor ($self->accessors) {
        no strict;

        *{ref($self) . '::' . $accessor} = sub {
            my $self = shift;

            if (! exists $self->{data}->{$accessor}) {
warn 'calling fetch for accessor: ' . $accessor;
                $self->fetch();
            }

            if (exists $self->{data}->{$accessor}) {
                return $self->{data}->{$accessor};
            }
        };
    }

    return;
}

sub _decode_textile {
    my ($self, $text) = @_;

    require Text::Textile;

    my $textile = Text::Textile->new(
        disable_html => 1,
    );

    return $textile->process($text);
}

1;
