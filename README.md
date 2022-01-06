# Kaleidos export for Themis

Export stack based on [mu.semte.ch](https://mu.semte.ch) to produce an export to be ingested in the [Themis application](https://themis.vlaanderen.be). Exports are created per meeting and published as delta files for interested consumers.

## How-to guides
### How to integrate the export stack with Kaleidos
The export stack runs next to the Kaleidos application stack. To get access to the data to be exported, the export stack will:
- joining the docker network of the Kaleidos application to query its triplestore
- mount the volume with Kaleidos documents

Hence, the export stack and the Kaleidos application stack are required to run on the same server.

#### Join Kaleidos application network

Add the Kaleidos network as an external network on the server in `docker-compose.override.yml`:

```yml
networks:
  kaleidos:
    external:
      name: app-kaleidos_default   # replace with the docker network name of the Kaleidos application
```

Next, make the `export` and `kaleidos-public-file` service join the `default` network as well as the external `kaleidos` network:

```yml
services:
  export:
    networks:
      - kaleidos
      - default
  kaleidos-public-file:
    networks:
      - kaleidos
      - default
```

Finally, configure the `KALEIDOS_SPARQL_ENDPOINT` environment variable of the export service depending the name of the Virtuoso service in the Kaleidos stack. Assuming the Virtuoso service is named `triplestore`, the environment variable `KALEIDOS_SPARQL_ENDPOINT` must be configured as `http://triplestore:8890/sparql`.

#### Mounting Kaleidos files

Bind mount the Kaleidos file volume as a volume in the `kaleidos-public-file` service on the server in `docker-compose.override.yml`:

```yml
services:
  kaleidos-public-file:
    volumes:
      - /data/app-kaleidos/data/files:/shared
```

#### Providing an alias for the database service
Services joining multiple networks may encounter service name collisions if services have the same name in both stacks. In case app-themis-export and the Kaleidos stack both contain a service named `database`, provide the following alias for the `database` service in `docker-compose.override.yml` of the app-themis-export stack to resolve the collision. As a consequence, the `MU_SPARQL_ENDPOINT` environment variable of the export service also needs to be updated to take the alias into account.

```
services:
  database:
    networks:
      default:
        aliases:
          - themis-export-database
  export:
    environment:
      MU_SPARQL_ENDPOINT: "http://themis-export-database:8890/sparql"

```

### How to trigger an export
The stack contains an admin frontend via which an export for a meeting can be triggered. It's up to the user to decide which facets of the meeting should be exported (e.g. only news items or documents as well).

Export files will be stored in `./data/exports`.

## Reference
### High-level flow of the data sync to Themis
The sync to Themis works with a pull-mechanism. This stack generates and provides publications, which are polled and fetched at regular intervals by the Themis stack.

This stack contains as main components:
- an [export service](https://github.com/kanselarij-vlaanderen/themis-export-service) responsible for collecting data from Kaleidos and generating a TTL data dump
- a [TTL to delta conversion service](https://github.com/redpencilio/ttl-to-delta-service) to convert the TTL data dump to the delta format
- a [producer service](https://github.com/kanselarij-vlaanderen/themis-publication-producer) providing an endpoint to fetch publications for interested consumers
- a [public file service](https://github.com/kanselarij-vlaanderen/public-file-service) providing an endpoint for interested consumers to fetch public Kaleidos documents

The main component of the [Themis stack](https://github.com/kanselarij-vlaanderen/app-themis) is the [Themis publication consumer service](https://github.com/kanselarij-vlaanderen/themis-publication-consumer) responsible for polling and fetching of the publications and accompanying documents.
