-- =============================================
-- =               DOMAINS                     =
-- =============================================

DO
$$
    BEGIN
        CREATE DOMAIN uint32 AS bigint
            CHECK (VALUE >= 0 AND VALUE < 4294967296);
    EXCEPTION
        WHEN duplicate_object THEN null;
    END
$$;

-- =============================================
-- =               TABLES                      =
-- =============================================

CREATE TABLE IF NOT EXISTS "user"
(
    id           SERIAL PRIMARY KEY,
    username     TEXT UNIQUE              NOT NULL,
    email        TEXT UNIQUE,
    display_name TEXT,
    password     TEXT                     NOT NULL,
    created_at   timestamp with time zone NOT NULL DEFAULT current_timestamp,
    is_admin     BOOLEAN                  NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS session
(
    id         SERIAL PRIMARY KEY,
    token      TEXT UNIQUE                                                        NOT NULL,
    name       TEXT,
    "user"     INTEGER REFERENCES "user" (id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    created_at timestamp with time zone                                           NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS permissions
(
    user_id     INTEGER REFERENCES "user" (id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    entity_type TEXT                                                               NOT NULL,
    entity_id   INTEGER                                                            NOT NULL,
    permissions INTEGER                                                            NOT NULL,
    PRIMARY KEY (user_id, entity_type, entity_id)
);

CREATE TABLE IF NOT EXISTS currency
(
    id             SERIAL PRIMARY KEY,
    name           TEXT    NOT NULL,
    symbol         TEXT    NOT NULL,
    iso_code TEXT,
    decimal_places INTEGER NOT NULL,
    "user"         INTEGER REFERENCES "user" (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS account
(
    id               SERIAL PRIMARY KEY,
    name             TEXT                                                                 NOT NULL,
    description      TEXT,
    iban             TEXT UNIQUE,
    balance          BIGINT                                                               NOT NULL DEFAULT 0,
    original_balance BIGINT                                                               NOT NULL DEFAULT 0,
    currency         INTEGER REFERENCES Currency (id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    created_at       timestamp with time zone                                             NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS budget
(
    id          SERIAL PRIMARY KEY,
    "user"      INTEGER REFERENCES "user" (id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    amount      BIGINT                                                             NOT NULL,
    name        TEXT                                                               NOT NULL,
    description TEXT,
    created_at  timestamp with time zone                                           NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS transaction_template
(
    id          SERIAL PRIMARY KEY,
    source      INTEGER REFERENCES account (id) ON UPDATE CASCADE ON DELETE CASCADE,
    destination INTEGER REFERENCES account (id) ON UPDATE CASCADE ON DELETE CASCADE,
    amount      BIGINT                                                               NOT NULL,
    currency    INTEGER REFERENCES currency (id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    name        TEXT                                                                 NOT NULL,
    description TEXT,
    budget      INTEGER REFERENCES budget (id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at  timestamp with time zone                                             NOT NULL DEFAULT current_timestamp,

    CHECK (source IS NOT NULL OR destination IS NOT NULL)
);

CREATE TABLE IF NOT EXISTS repeatable_transaction
(
    id                      SERIAL PRIMARY KEY,
    template                INTEGER REFERENCES transaction_template (id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    repeat_interval_seconds uint32                                                                           NOT NULL,
    created_at              timestamp with time zone                                                         NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS transaction
(
    id          SERIAL PRIMARY KEY,
    source      INTEGER REFERENCES Account (id) ON UPDATE CASCADE ON DELETE CASCADE,
    destination INTEGER REFERENCES Account (id) ON UPDATE CASCADE ON DELETE CASCADE,
    amount      BIGINT                   NOT NULL,
    currency    INTEGER REFERENCES Currency (id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    name        TEXT                     NOT NULL,
    description TEXT,
    budget      INTEGER REFERENCES budget (id) ON UPDATE CASCADE ON DELETE CASCADE,
    executed_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    created_at  timestamp with time zone NOT NULL DEFAULT current_timestamp,
    CHECK (source IS NOT NULL OR destination IS NOT NULL)
);
