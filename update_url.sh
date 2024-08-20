#/bin/bash


SQLCONTAINER_LABEL=$(grep -o '^\s\s\$*mysql:$' docker-compose.yaml)
SQLCONTAINER_NAME="$(basename $WORK)_${CONTAINER_LABEL:2:-1}mysql_1"


# update the URL, to match docker-compose's port forwarding
# This may have to be modified, depending if you do reverse proxy
USE=$(grep 'MYSQL_DATABASE: ' docker-compose.yaml|cut -d: -f2)
USR=$(grep 'MYSQL_USER: ' docker-compose.yaml|cut -d: -f2)
PWD=$(grep 'MYSQL_PASSWORD: ' docker-compose.yaml|cut -d: -f2)

if [ ! -f update_url.sql.original ]; then
  cp -f update_url.sql update_url.sql.original
fi
cp -f update_url.sql.original update_url.sql
sed -i "s/DATABASE_NAME/${USE}/g;s/hostname/$(hostname)/g" update_url.sql

docker exec -i $SQLCONTAINER_NAME mysql -u $USR -p$PWD < update_url.sql




echo "changed the wordpress database, to use http://$(hostname)/ as redirect URL, and links."