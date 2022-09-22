#!/bin/bash

# 1. change DB name in ./config/dev.exs to `rdb` (`database: "rdb"`)
# 2. ./db-restore.sh

DB_CONTAINER=db
DB_NAME=gateway_dev
DB_USER=postgres
LOCAL_DUMP_PATH="./13707b42-36b5-459b-a5d9-9f63c4026276.custom"

docker-compose exec -T "${DB_CONTAINER}" pg_restore -C --clean --no-acl --no-owner -U "${DB_USER}" -d "${DB_NAME}" < "${LOCAL_DUMP_PATH}"
