#!/bin/bash
flyway -community \
  -url="jdbc:postgresql://${FLYWAY_POSTGRES_HOST}:${FLYWAY_POSTGRES_PORT:-5432}/${FLYWAY_POSTGRES_DB}" \
  -user="${FLYWAY_POSTGRES_USER}" \
  -password="$(cat ${FLYWAY_POSTGRES_PASSWORD_FILE})" \
  -connectRetries=${FLYWAY_CONNECT_RETRIES:-10} \
  -schemas="${FLYWAY_SCHEMAS:-public}" \
  -table="${FLYWAY_TABLE:-schema_history}" \
  -locations="${FLYWAY_LOCATIONS}" \
  -failOnMissingLocations=true \
  -encoding="${FLYWAY_ENCODING:-UTF-8}" \
  migrate
