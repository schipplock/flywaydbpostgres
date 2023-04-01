# Flywaydb Docker Image

Das hier ist mein Docker Image für Flywaydb (9.16.1).
Die Basis ist Ubuntu 22.04. Deutsche Locale und Uhrzeit sind vorkonfiguriert.
"Mein" Flywaydb **unterstützt nur Postgres**.

## Wie benutze ich das Image?

Das Verhalten von Flywaydb wird über Umgebungsvariablen gesteuert.
Im Ordner `sql-migrations` liegen zwei Testmigrationen.

**Hier ein Beispiel für `docker-compose`:**

```yaml
services:

  flywaydb:
    image: docker.schipplock.de/flywaydb:9.16.1
    container_name: flywaydb
    networks:
      local-net:
        aliases:
          - flywaydb
    secrets:
      - postgres_password
    environment:
      FLYWAY_POSTGRES_HOST: db
      FLYWAY_POSTGRES_PORT: 5432
      FLYWAY_POSTGRES_USER: db
      FLYWAY_POSTGRES_DB: db
      FLYWAY_POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
      FLYWAY_CONNECT_RETRIES: 5
      FLYWAY_SCHEMAS: "public"
      FLYWAY_TABLE: "schema_history"
      FLYWAY_LOCATIONS: "filesystem:/migrations"
      FLYWAY_ENCODING: "UTF-8"
    volumes:
      - ./sql-migrations:/migrations:ro
    depends_on:
      - db
```

In diesem Repository liegt eine funktionierende `docker-compose.yml` dabei.

## Das Image bauen

Ich stelle das Docker-Image zwar in meiner eigenen Docker Registry zur Verfügung.
Man kann das Image aber selbstverständlich auch selber bauen.

```bash
docker build --no-cache --network=host --force-rm -t docker.schipplock.de/flywaydb:9.16.1 .
```

## Das Image in die Registry pushen

Das funktioniert natürlich nur, wenn man den Zugang kennt. Diese Info habe ich für mich selbst hier dokumentiert.

```bash
docker push docker.schipplock.de/flywaydb:9.16.1
docker tag docker.schipplock.de/flywaydb:9.16.1 docker.schipplock.de/flywaydb:latest
docker push docker.schipplock.de/flywaydb:latest
```