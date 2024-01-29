#!/usr/bin/env bash

sea-orm-cli generate entity -o entity/src/new -u postgresql://financrr:password@localhost:5432/financrr --lib --with-copy-enums --with-serde both
