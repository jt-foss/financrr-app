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
    name             TEXT                             NOT NULL,
    description      TEXT,
    iban             TEXT UNIQUE,
    balance          BIGINT                           NOT NULL DEFAULT 0,
    original_balance BIGINT                           NOT NULL DEFAULT 0,
    currency         INTEGER REFERENCES Currency (id) NOT NULL,
    created_at       timestamp with time zone         NOT NULL DEFAULT current_timestamp
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

CREATE TABLE IF NOT EXISTS transaction
(
    id          SERIAL PRIMARY KEY,
    source      INTEGER REFERENCES Account (id),
    destination INTEGER REFERENCES Account (id),
    amount      BIGINT                           NOT NULL,
    currency    INTEGER REFERENCES Currency (id) NOT NULL,
    description TEXT,
    budget      INTEGER REFERENCES budget (id),
    created_at  timestamp with time zone         NOT NULL DEFAULT current_timestamp,
    executed_at timestamp with time zone         NOT NULL DEFAULT current_timestamp,
    CHECK (source IS NOT NULL OR destination IS NOT NULL)
);
