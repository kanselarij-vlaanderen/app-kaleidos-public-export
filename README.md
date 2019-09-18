# Kaleidos export for Publieksontsluiting

Export stack based on [mu.semte.ch](https://mu.semte.ch) to generate an export to be ingested in the Publieksontsluiting application. An export consists of a Turtle file and a ZIP package with downloadable documents. Exports are created per session.

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

## Creating an export

TODO
