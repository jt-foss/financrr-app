CREATE TABLE currency
(
	id             SERIAL PRIMARY KEY,
	name           TEXT        NOT NULL,
	symbol         TEXT        NOT NULL,
	iso_code       TEXT UNIQUE NOT NULL,
	decimal_places INTEGER     NOT NULL
);

CREATE TABLE "user"
(
	id         SERIAL PRIMARY KEY,
	username   TEXT UNIQUE NOT NULL,
	email      TEXT UNIQUE,
	password   TEXT        NOT NULL,
	created_at TIMESTAMP   NOT NULL DEFAULT current_timestamp,
	is_admin   BOOLEAN     NOT NULL DEFAULT FALSE
);

CREATE TABLE account
(
	id          SERIAL PRIMARY KEY,
	owner       INTEGER REFERENCES "user" (id)   NOT NULL,
	name        TEXT UNIQUE                      NOT NULL,
	description TEXT,
	iban        TEXT UNIQUE,
	balance     INTEGER                          NOT NULL DEFAULT 0,
	currency    INTEGER REFERENCES Currency (id) NOT NULL,
	created_at  TIMESTAMP                        NOT NULL DEFAULT current_timestamp
);

CREATE TABLE user_account
(
	user_id    INTEGER REFERENCES "user" (id) ON UPDATE CASCADE ON DELETE CASCADE,
	account_id INTEGER REFERENCES Account (id) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY (user_id, account_id)
);

CREATE TABLE transaction
(
	id          SERIAL PRIMARY KEY,
	source      INTEGER REFERENCES Account (id),
	destination INTEGER REFERENCES Account (id),
	amount      INTEGER                          NOT NULL,
	currency    INTEGER REFERENCES Currency (id) NOT NULL,
	description TEXT,
	created_at  TIMESTAMP                        NOT NULL DEFAULT current_timestamp,
	executed_at TIMESTAMP                        NOT NULL DEFAULT current_timestamp
);
