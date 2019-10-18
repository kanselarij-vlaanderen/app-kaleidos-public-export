#!/bin/bash
echo "Don't forget to update the meetings to be exported in ./src/batch/batch.rb"
read -p "Do you want to cleanup previous exports [y/n]? " -n 1 -r
echo    #  move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    docker-compose -f docker-compose.yml -f docker-compose.batch.yml -f docker-compose.override.yml down
    echo "Reset Virtuoso"    
    pushd data/db
    rm .data_loaded .dba_pwd_set virtuoso{-temp.db,.db,.log,.pxa,.trx}
    popd
    echo "Remove previous TTL exports"
    rm data/exports/valvas/*
    echo "Remove previous file exports"    
    rm data/files/*
fi

docker-compose up -d virtuoso
sleep 3
docker-compose up -d
sleep 3
docker-compose -f docker-compose.yml -f docker-compose.batch.yml -f docker-compose.override.yml up -d batch-ttl

echo
echo "Started the export. Resulting TTLs will be written to ./data/exports/valvas"
echo "You can follow-up the progress of the export via: drc logs -ft --tail=100 export"
echo
echo "What to do next? When the export is finished:"
echo "- Copy the news-items and mededelingen migrations to the Valvas app on the vo-pages-dev server"
echo "- Restart the migrations service on vo-pages-dev server"
echo "- Reindex using reset-elastic.sh on vo-pages-dev server"
echo "- Restart resource and cache service on vo-pages-dev server and make sure you see the new meeting(s) in Valvas without documents"
echo "- Copy the resulting index and migrations to the production server. Restart resource and cache service"
echo "- Export the files once they are released (probably next Monday) using create-file-export.sh"
