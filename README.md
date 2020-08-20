# Kaleidos export for Valvas

Export stack based on [mu.semte.ch](https://mu.semte.ch) to produce an export to be ingested in the Valvas application. Exports are created per session and published as delta files for interested consumers.

## How-to guides
### How to integrate the export stack with Kaleidos
The export stack runs next to the Kaleidos application stack. To get access to the data to be exported, the export stack will:
- joining the docker network of the Kaleidos application to query its triplestore
- mount the volume with Kaleidos documents

Hence, the export stack and the Kaleidos application stack are required to run on the same server.

#### Join Kaleidos application network

Add the Kaleidos network as an external network on the server in `docker-compose.override.yml`:

```
networks:
  kaleidos:
    external:
      name: app-kaleidos_default   # replace with the docker network name of the Kaleidos application
```

Next, make the `export` and `kaleidos-public-file` service join the `default` network as well as the external `kaleidos` network:

```
services:
  export:
    networks:
      - kaleidos
      - default
  kaleidos-public-file
    networks:
      - kaleidos
      - default
```

Finally, configure the `KALEIDOS_SPARQL_ENDPOINT` environment variable of the export service depending the name of the Virtuoso service in the Kaleidos stack. Assuming the Virtuoso service is named `triplestore`, the environment variable `KALEIDOS_SPARQL_ENDPOINT` must be configured as `http://triplestore:8890/sparql`.

#### Mounting Kaleidos files

Bind mount the Kaleidos file volume as a volume in the `kaleidos-public-file` service on the server in `docker-compose.override.yml`:

```
services:
  kaleidos-public-file
    volumes:
      - /data/app-kaleidos/data/files:/shared
```

#### Providing an alias for the database service
Services joining multiple networks may encounter service name collisions if services have the same name in both stacks. In case app-valvas-export and the Kaleidos stack both contain a service named `database`, provide the following alias for the `database` service in `docker-compose.override.yml` of the app-valvas-export stack to resolve the collision. As a consequence, the `MU_SPARQL_ENDPOINT` environment variable of the export service also needs to be updated to take the alias into account.

```
services:
  database:
    networks:
      default:
        aliases:
          - valvas-export-database
  export:
    environment:
      MU_SPARQL_ENDPOINT: "http://valvas-export-database:8890/sparql"

```

### How to trigger an export
The stack contains an admin frontend via which an export for a session can be triggered. It's up to the user to decide which facets of the session should be exported (e.g. only news items and announcements or documents as well). A notification about the publication of the documents can be configured via this GUI as well.

### How to monitor the progress of an export
To monitor the progress of the TTL export, execute the following SPARQL query:

```
SELECT COUNT(?s) ?status WHERE {
  GRAPH <http://mu.semte.ch/graph/public-export-jobs> {
     ?s a <http://mu.semte.ch/vocabularies/ext/PublicExportJob> ; <http://mu.semte.ch/vocabularies/ext/status> ?status .
  }
} GROUP BY ?status
```

The resulting files, TTL as well as delta files, will be written to `./data/exports/valvas`.
