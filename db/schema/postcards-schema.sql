-- postcards table
CREATE TABLE IF NOT EXISTS postcards (
    id           INTEGER NOT NULL,
    from_country TEXT    NOT NULL,
    to_country   TEXT    NOT NULL,
    recipients   TEXT    NOT NULL,
    title        TEXT    NOT NULL,
    seo          TEXT    NOT NULL,
    content      TEXT    NOT NULL,
    content_raw  TEXT    NOT NULL,
    media        TEXT    NOT NULL,
    pubdate      INTEGER NOT NULL,
    lang         TEXT    NOT NULL,
    is_draft     INTEGER NOT NULL DEFAULT 1,

    PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS i_is_draft ON postcards (is_draft);
