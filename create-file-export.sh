echo "A ZIP package containing the public files will be created for each exported meeting that is currently in the triplestore"
docker-compose up -d virtuoso
sleep 3
docker-compose up -d
sleep 3
docker-compose -f docker-compose.yml -f docker-compose.batch.yml -f docker-compose.override.yml up -d batch-file

echo
echo "Started the export. Resulting ZIPs will be written to ./data/files"
echo "You can follow-up the progress of the export via: drc logs -ft --tail=100 file-packaging"
echo
echo "What to do next? When the export is finished:"
echo "- Copy the documents and migrations to the Valvas app on the vo-pages-dev server"
echo "- Restart the migrations, resource and cache service on vo-pages-dev server"
echo "- If it works, do the same on the production server"

