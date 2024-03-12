#!/usr/bin/env bash

sea-orm-cli generate entity -o entity/src/new \
	--lib \
	--with-copy-enums \
	--with-serde both \
	--date-time-crate time\
	-u postgresql://financrr:password@localhost:5432/financrr
