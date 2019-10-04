# Kaleidos export for Valvas

Export stack based on [mu.semte.ch](https://mu.semte.ch) to generate an export to be ingested in the Valvas application. An export consists of Turtle files and a ZIP package with downloadable documents. Exports are created per session.

## Configuration

The export stack runs next to the Kaleidos application stack. To get access to the data to be exported, the export stack will:
- joining the docker network of the Kaleidos application to query its triplestore
- mount the volume with Kaleidos documents

### Join Kaleidos application network

Add the Kaleidos network as an external network on the server in `docker-compose.override.yml`:

```
networks:
  kaleidos:
    external:
      name: app-kaleidos_default   # replace with the docker network name of the Kaleidos application
```

Next, make the export service join the `default` network as well as the external `kaleidos` network:

```
services:
  export:
    networks:
      - kaleidos
      - default
```

Finally, configure the `KALEIDOS_SPARQL_ENDPOINT` environment variable of the export service depending the name of the Virtuoso service in the Kaleidos stack. Assuming the Virtuoso service is named `database`, the environment variable `KALEIDOS_SPARQL_ENDPOINT` must be configured as `http://database:8890/sparql`.

### Mounting Kaleidos files

Bind mount the Kaleidos file volume as a volume in the file-packaging service on the server in `docker-compose.override.yml`:

```
services:
  file-packaging:
    volumes:
      - /data/app-kaleidos/data/files:/data/original-files
```

## Preparing an export for Valvas

An export exists of TTL files and ZIP packages containing the files.

For each session, 3 TTL files and 1 ZIP package are generated. The TTL files contain:
1. nieuwsbrief info resources for KB
2. mededelingen
3. documents and related files

### Creating a new export

The services to create an export are configured in `docker-compose.batch.yml`. Make sure both services, `batch-ttl` and `batch-file` have access to the `default` and the external `kaleidos` network.

First, start Virtuoso.
```
docker-compose up -d virtuoso
```

If Virtuoso started successfully, start the remaining services of the default stack.
```
docker-compose up -d
```

Next, trigger the export of the TTL files for one or more sessions. The SPARQL query to select the sessions to be exported is defined in `./src/batch/batch.rb`.

```
docker-compose -f docker-compose.yml -f docker-compose.batch.yml -f docker-compose.override.yml up -d batch-ttl
```

Once the TTL export jobs are finished, start the file export for all jobs.
```
docker-compose -f docker-compose.yml -f docker-compose.batch.yml -f docker-compose.override.yml up -d batch-file
```

If an export is done, stop the stack and reset Virtuoso for the next export.
```
docker-compose -f docker-compose.yml -f docker-compose.batch.yml -f docker-compose.override.yml down
./reset-virtuoso.sh
```

### Monitor the progress of an export

To monitor the progress of the TTL export, execute the following SPARQL query:

```
SELECT COUNT(?s) ?status WHERE {
  GRAPH <http://mu.semte.ch/graph/public-export-jobs> {
     ?s a <http://mu.semte.ch/vocabularies/ext/PublicExportJob> ; <http://mu.semte.ch/vocabularies/ext/status> ?status .
  }
} GROUP BY ?status
```

To monitor the progress of the file export, execute the following SPARQL query:
```
SELECT ?status COUNT(?s) WHERE {
  ?s a <http://mu.semte.ch/vocabularies/ext/simple-file-package-service/SimpleFilePackageJob> ; <http://mu.semte.ch/vocabularies/ext/simple-file-package-service/status> ?status
} GROUP BY ?status
```
