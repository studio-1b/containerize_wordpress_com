#/bin/bash

# this started at Thu Jun 27 11:55:42 PM PDT 2024
# and ended       Fri Jun 28 02:16:18 AM PDT 2024
# so 4h 24m... Why did it take 3+ hour and not finish at Whole Foods Wifi?

WP_URL=$1
if [ "$WP_URL" == "" ]; then
  echo "Tested as of 6/21/2024, on Wordpress.com, to get export"
  echo "USAGE: containerize_wordpress_com.sh [wordpress url] [wordpress username]"
  echo "       There should be file named the same as your wordpress username, and contents is wordpress password"
  echo "USAGE: containerize_wordpress_com.sh [wordpress export file]"
  exit 1
fi
if [ "${WP_URL:0:8}" == "https://" ]; then
  curl $WP_URL &> /dev/null
  if [ $? -ne 0 ]; then
    echo "ERROR: unable to connect to: $WP_URL"
    echo "did you enter it correctly?"
    exit 2
  fi
  curl $WP_URL/wp-login.php &> /dev/null
  if [ $? -ne 0 ]; then
    echo "ERROR: Cannect find login page: $WP_URL"
    echo "Is the site correct?"
    exit 2
  fi
else
  echo "URL did not start with https:// : $WP_URL"
  echo assuming $WP_URL is a filename

  FILENAME=${WP_URL%.*}
  TAR_FILE=$FILENAME.tar
  WXL_FILE=$FILENAME.xml

  if [ ! -f $TAR_FILE ]; then
    echo "Did not find file: $TAR_FILE"
    echo "expecting $TAR_FILE and $WXL_FILE"
    exit 3
  fi
  echo "Found file: $TAR_FILE"

  if [ ! -f $WXL_FILE ]; then
    echo "Did not find file: $WXL_FILE"
    echo "expecting $TAR_FILE and $WXL_FILE"
    exit 3
  fi
  echo "Found file: $WXL_FILE"
  echo "Both required files found, skipping URL"
  IS_WXL_AND_TAR_EXISTS="Y"
  WP_URL=""
fi




# Getting exports remotely
if [ "$IS_WXL_AND_TAR_EXISTS" != "Y" ]; then
  WP_USERNAME_FILE=$2
  WP_USERNAME=$(basename $WP_USERNAME_FILE)
  if [ "$WP_USERNAME_FILE" == "" ]; then
    echo "USAGE: containerize_wordpress_com.sh [wordpress url] [wordpress username]"
    exit 1
  fi
  if [ ! -f "$WP_USERNAME_FILE" ]; then
    echo "USAGE: containerize_wordpress_com.sh [wordpress url] [wordpress username]"
    echo "       [wordpress username] must exist"
    echo "                                and it contains password"
    exit 2
  fi
  WP_PASSWORD=$(<$WP_USERNAME_FILE)



  #* About to connect() to ____.wordpress.com port 443 (#0)
  #*   Trying 107.180.58.68... connected
  #* Connected to ____.wordpress.com (107.180.58.68) port 443 (#0)
  #* Initializing NSS with certpath: sql:/etc/pki/nssdb
  #*   CAfile: /etc/pki/tls/certs/ca-bundle.crt
  #  CApath: none
  #* SSL connection using TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
  #* Server certificate:
  #*       subject: CN=____.wordpress.com
  #*       start date: Apr 11 11:07:59 2024 GMT
  #*       expire date: May 13 11:07:59 2025 GMT
  #*       common name: ____.wordpress.com
  #*       issuer: CN=Go Daddy Secure Certificate Authority - G2,OU=http://certs.godaddy.com/repository/,O="GoDaddy.com, Inc.",L=Scottsdale,ST=Arizona,C=US
  #> POST /wp-login.php HTTP/1.1
  #> User-Agent: curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.44 zlib/1.2.3 libidn/1.18 libssh2/1.4.2
  #> Host: ____.wordpress.com
  #> Accept: */*
  #> Cookie: wordpress_test_cookie=WP+Cookie+check
  #> Content-Type: application/x-www-form-urlencoded
  #> Content-Length: 137
  #>
  #< HTTP/1.1 302 Found
  #< Date: Mon, 03 Jun 2024 02:17:05 GMT
  #< Server: Apache
  #< X-Powered-By: PHP/7.3.33
  #< Expires: Wed, 11 Jan 1984 05:00:00 GMT
  #< Cache-Control: no-cache, must-revalidate, max-age=0
  #< X-Frame-Options: SAMEORIGIN
  #< Set-Cookie: wordpress_test_cookie=WP+Cookie+check; path=/; secure
  #< Set-Cookie: wordpress_sec_de8dbb9b8b98b7d006262ee5af2cb904=; path=/blog/wp-content/plugins; secure; HttpOnly
  #< Set-Cookie: wordpress_sec_de8dbb9b8b98b7d006262ee5af2cb904=export_user%7C1717553825%7C6Xb3DxDxJUsrs63v3nzBJ216vMAKWu4SbI5gLS8u7mZ%=; path=/blog/wp-admin; secure; HttpOnly
  #< Set-Cookie: wordpress_logged_in_de8dbb9b8b98b7d006262ee5af=export_user%7C1717553825%7C6Xb3DxDxJUsrs63v3nzBJ216vMAKWu4SbI5gLS=; path=/blog/; HttpOnly
  #< Upgrade: h2,h2c
  #< Connection: Upgrade
  #< Location: https://_____.wordpress.com/wp-admin/
  #< Vary: Accept-Encoding
  #< Content-Length: 0
  #< Content-Type: text/html; charset=UTF-8
  #<
  #* Connection #0 to host _____.wordpress.com left intact
  #* Closing connection #0

  curl -v -X POST $WP_URL/wp-login.php -H "Content-Type: application/x-www-form-urlencoded" -d "log=$WP_USERNAME&pwd=$WP_PASSWORD&wp-submit=Log+In&redirect_to=https%3A%2F%2F____.wordpress.com%2Fblog%2Fwp-admin%2F&testcookie=1"  --cookie "wordpress_test_cookie=WP+Cookie+check" &> containerize_wordpress_com.tmp
  grep -i "< Location: $WP_URL/wp-admin/" containerize_wordpress_com.tmp > /dev/null
  if [ $? -ne 0 ]; then
    echo "Error!  Login to wordpress website failed"
    echo "see containerize_wordpress_com.tmp for details"
    echo "did you supply the correct username, and have a file with same name, with password inside?"
    exit 3
  fi

  grep -i '< Set-Cookie: ' containerize_wordpress_com.tmp > /dev/null
  if [ $? -ne 0 ]; then
    echo "Error! Cannot find login cookie"
    echo "see containerize_wordpress_com.tmp for details"
    echo "should have: set-cookie"
    exit 4
  fi

  WP_COOKIE=$(grep -i '< Set-Cookie: ' containerize_wordpress_com.tmp | cut -d';' -f1 | cut -c15- | tr '\n' ';')
  curl -v $WP_URL'/wp-admin/export.php?download=true&content=all&cat=0&post_author=0&post_start_date=0&post_end_date=0&post_status=0&page_author=0&page_start_date=0&page_end_date=0&page_status=0&attachment_start_date=0&attachment_end_date=0&fl-builder-template-export-select=all&submit=Download+Export+File' --cookie "$WP_COOKIE" -o wordpress.$WP_USERNAME.xml 2>&1 | grep -i '< Content-Disposition: attachment; filename='
  if [ $? -ne 0 ]; then
    echo "ERROR!  the download reported error $?.  Please look at above output for clues"
    exit 5
  fi
  if [ ! -f "wordpress.$WP_USERNAME.xml" ]; then
    echo "ERROR!  cannot find export file"
    exit 6
  fi
  WXL_FILE="wordpress.$WP_USERNAME.xml"
  echo "WXL export file is: wordpress.$WP_USERNAME.xml"

  curl -v $WP_URL'/wp-admin/export.php?download=true&content=all&cat=0&post_author=0&post_start_date=0&post_end_date=0&post_status=0&page_author=0&page_start_date=0&page_end_date=0&page_status=0&attachment_start_date=0&attachment_end_date=0&fl-builder-template-export-select=all&submit=Download+Export+File' --cookie "$WP_COOKIE" -o wordpress.$WP_USERNAME.tar 2>&1 | grep -i '< Content-Disposition: attachment; filename='
  if [ $? -ne 0 ]; then
    echo "ERROR!  the download reported error $?.  Please look at above output for clues"
    exit 5
  fi
  if [ ! -f "wordpress.$WP_USERNAME.xml" ]; then
    echo "ERROR!  cannot find export file"
    exit 6
  fi
  TAR_FILE="wordpress.$WP_USERNAME.tar"
  echo "TAR export file is: wordpress.$WP_USERNAME.tar"
fi




# Verifying files are valid
echo "Examining export file $WXL_FILE"
grep '<wp:author_login>[^<]' $WXL_FILE 
if [ $? -eq 0 ]; then
  echo "found inconsistency.  Copying original to $WXL_FILE.original, then fixing"
  cp $WXL_FILE $WXL_FILE.original
  sed -i 's/<wp:author_login>/<wp:author_login><![CDATA[/g;s|</wp:author_login>|]]></wp:author_login>|g;s/<wp:author_email>/<wp:author_email><![CDATA[/g;s|</wp:author_email>|]]></wp:author_email>|g' $WXL_FILE
  echo "new changes in $WXL_FILE"
fi






# Prepaing wordpress config and containers
if [ "$WP_URL" != "" ]; then
  CONTAINER_PREFIX="$(basename $WP_URL|tr '.' '-')"
else
  CONTAINER_PREFIX="$(echo $FILENAME|tr '.' '-')"
fi
echo "Using $CONTAINER_PREFIX as container name"
USED_LOCAL_PORTS=$(docker ps --format '{{.Ports}}' | grep -o  :[0-9]*-)
NEW_PORT=8888
echo $USED_LOCAL_PORTS | grep ":${NEW_PORT}-" &>/dev/null
while [ $? -ne 0 ];do
  NEW_PORT=$(( NEW_PORT + 1 ))
  echo $USED_LOCAL_PORTS | grep ":${NEW_PORT}-" &>/dev/null
done
echo "Using $NEW_PORT as new local port for container"
echo "We use first unused port by docker after 8888"
echo "And hope it isn't used by other processes"

grep prefix docker-compose.yaml
if [ $? -ne 0 ]; then
  echo "This script has been run before.  docker-compose was modified"
  echo "This will overwrite the previous settings.  Do you want to proceed(y/n)?"
  echo "Enter y to proceed, or it will abort"
  read ANSWER
  if [ "$ANSWER" != "y" ]; then
    echo "Aborted!"
    exit 1
  fi
  mv -f docker-compose.yaml.original docker-compose.yaml
fi
if [ ! -f docker-compose.yaml.original ]; then
  cp docker-compose.yaml docker-compose.yaml.original
fi
echo "s/prefix/$CONTAINER_PREFIX/g;s/HOST_PORT/$NEW_PORT/g"
sed "s/prefix/$CONTAINER_PREFIX/g;s/HOST_PORT/$NEW_PORT/g" docker-compose.yaml
echo "Does this look right? (y/n)"
read DELAY
if [ "$DELAY" != "y" ]; then
  echo "aborted!"
  exit 4
fi
sed -i "s/prefix/$CONTAINER_PREFIX/g" docker-compose.yaml
echo "changes made to docker-compose.yaml"

#docker-compose -d up
echo "starting wordpress containers"
docker pull wordpress:latest
docker pull mysql:latest
docker-compose up -d

WORK=$(pwd)
CONTAINER_NAME="$(basename $WORK)_${CONTAINER_PREFIX}php_1"
docker ps -f name=$CONTAINER_NAME | grep "$CONTAINER_NAME"
if [ $? -ne 0 ]; then
  echo "This script won't work"
  echo "It is expecting the new container for wordpress to be named: $CONTAINER_NAME"
  exit 1
fi
SQLCONTAINER_NAME="$(basename $WORK)_${CONTAINER_PREFIX}mysql_1"
docker ps -f name=$SQLCONTAINER_NAME | grep "$SQLCONTAINER_NAME"
if [ $? -ne 0 ]; then
  echo "This script won't work"
  echo "It is expecting the new container for mysql to be named: $SQLCONTAINER_NAME"
  exit 1
fi
echo "Verified container names are: $CONTAINER_NAME $SQLCONTAINER_NAME"

sleep 30
AGAIN="y"
while [ "$AGAIN" == "y" ]; do
  AGAIN="N"
  curl -v http://localhost:8889 &> wordpress.html
  if [ $? -ne 0 ]; then
      echo "no response from wordpress container.  Is it up?  Exiting rest of set up, now."
      #exit 1
      AGAIN="y"
  fi
  grep "Error establishing a database connection" wordpress.html
  if [ $? -eq 0 ]; then
      echo "there is problem with docker-compose.yml"
      echo "the default wordpress install, cannot connect w mysql"
      #exit 2
      AGAIN="y"
  fi
  if [ "$AGAIN" == "y" ]; then
    echo "Try again?  If this is first attempt to start docker-compose file, this can take 60sec?  (y/n)"
    read AGAIN
  fi
done

#curl -v http://localhost:8888/dfdfsd
#* processing: http://localhost:8888/dfdfsd
#*   Trying [::1]:8888...
#* Connected to localhost (::1) port 8888
#> GET /dfdfsd HTTP/1.1
#> Host: localhost:8888
#> User-Agent: curl/8.2.1
#> Accept: */*
#> 
#< HTTP/1.1 302 Found
#< Date: Tue, 28 May 2024 02:55:24 GMT
#< Server: Apache/2.4.59 (Debian)
#< X-Powered-By: PHP/8.2.19
#< Expires: Wed, 11 Jan 1984 05:00:00 GMT
#< Cache-Control: no-cache, must-revalidate, max-age=0
#< X-Redirect-By: WordPress
#< Location: http://localhost:8888/wp-admin/install.php
grep "HTTP/1.1 302 Found" wordpress.html
if [ $? -ne 0 ]; then
    echo "Not expected result"
    echo "expected 302 redirect"
    echo "stopping here, bc install doesnt know if it needs to replace files"
    exit 2
fi
grep "Location: http://localhost:8889/wp-admin/install.php" wordpress.html
if [ $? -ne 0 ]; then
    echo "not expected result"
    echo "expected a redirect to install page"
    echo "stopping here, bc install doesnt know if it needs to replace files"
    exit 2
fi





# configuring wordpress, and installing content
# installing wp-cli
docker exec $CONTAINER_NAME  curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /tmp/wp-cli.phar
docker exec $CONTAINER_NAME  php /tmp/wp-cli.phar --info
docker exec $CONTAINER_NAME  chmod +x /tmp/wp-cli.phar
docker exec $CONTAINER_NAME  mv /tmp/wp-cli.phar /usr/local/bin/wp

# copying the data downloaded from live site, to container
docker cp  $WXL_FILE   $CONTAINER_NAME:/tmp
docker cp  $TAR_FILE   $CONTAINER_NAME:/tmp

# replace PHP for wordpress
# https://www.wpbeginner.com/beginners-guide/which-wordpress-files-should-you-backup-and-the-right-way-to-do-it/
# wp-config.php
# .htaccess
# wp-content/*
#docker cp  $CONTAINER_NAME:/var/www/html/wp-config.php .
#docker exec $CONTAINER_NAME  rm -R /var/www/html/*
#docker exec -w /var/www/html/wp-content/ $CONTAINER_NAME  tar xvzf /tmp/$TAR_FILE
docker exec -w /var/www/html/wp-content/ $CONTAINER_NAME  tar xvf /tmp/$TAR_FILE
docker exec -w /var/www/html/wp-content/ $CONTAINER_NAME  rm /tmp/$TAR_FILE
docker exec -w /var/www/html/wp-content/ $CONTAINER_NAME  chown www-data upgrade
docker exec -w /var/www/html/wp-content/ $CONTAINER_NAME  chgrp www-data upgrade
docker exec -w /var/www/html/wp-content/ $CONTAINER_NAME  chown www-data [0-9][0-9][0-9][0-9]
docker exec -w /var/www/html/wp-content/ $CONTAINER_NAME  chgrp www-data [0-9][0-9][0-9][0-9]
#docker exec $CONTAINER_NAME  cp -R blog/.htaccess .
#docker exec $CONTAINER_NAME  cp -R blog/wp-config.php .
#docker exec $CONTAINER_NAME  cp -R blog/wp-content/ .
#docker cp  wp-config.php $CONTAINER_NAME:/var/www/html/wp-config.php

# run import of export file
LOCAL_WP_URL="$(hostname):NEW_PORT"
NEW_WP_ADMIN="admin"
if [ -f $NEW_WP_ADMIN ]; then
  NEW_WP_PASSWORD=$(<$NEW_WP_ADMIN)
else
  NEW_WP_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
  echo $NEW_WP_PASSWORD > $NEW_WP_ADMIN
fi
docker exec -w /var/www/html/ $CONTAINER_NAME  wp core install --allow-root --url=$LOCAL_WP_URL --title=Test.$WP_URL  --admin_user=$NEW_WP_ADMIN --admin_password=$NEW_WP_PASSWORD --admin_email=$NEW_WP_ADMIN@localhost.localdomain

docker exec -w /var/www/html/ $CONTAINER_NAME  wp plugin install wordpress-importer --activate --allow-root
docker exec -w /var/www/html/ $CONTAINER_NAME  wp import /tmp/$WXL_FILE --authors=create --allow-root
docker exec -w /var/www/html/ $CONTAINER_NAME  rm /tmp/$WXL_FILE
#ocker exec -w /var/www/html/ $CONTAINER_NAME   wp theme install twentysixteen --activate
#ocker exec -w /var/www/html/ $CONTAINER_NAME   wp theme install Revelar --activate

# Install googlemap embed shortcode from a local zip file
#$ wp plugin install ../my-plugin.zip
docker cp  bob-shortcode-plugin.zip   $CONTAINER_NAME:/tmp/
docker exec -w /var/www/html/ $CONTAINER_NAME  wp plugin install /tmp/bob-shortcode-plugin.zip --activate


# update the URL, to match docker-compose's port forwarding
# This may have to be modified, depending if you do reverse proxy
USE=$(grep 'MYSQL_DATABASE: ' docker-compose.yaml|cut -d: -f2)
USR=$(grep 'MYSQL_USER: ' docker-compose.yaml|cut -d: -f2)
PWD=$(grep 'MYSQL_PASSWORD: ' docker-compose.yaml|cut -d: -f2)
if [ ! -f update_url.sql.original ]; then
  cp -f update_url.sql update_url.sql.original
fi
cp -f update_url.sql.original update_url.sh
sed -i "s/DATABASE_NAME/${USE}/g" update_url.sql
docker exec -i $SQLCONTAINER_NAME mysql -u $USR -p$PWD < update_url.sql



# create container image
NOW=$(date +%Y.%m.%d)
OPTIONAL_PHP_IMAGE_REPO=$3
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 166053251688.dkr.ecr.us-east-1.amazonaws.com
if [ "$OPTIONAL_PHP_IMAGE_REPO" != "--" ]; then
  echo "Processing $OPTIONAL_PHP_IMAGE_REPO"
  #docker build --progress=plain -t site_wp .      #instruction to build a image from a Dockerfile
  #docker commit $CONTAINER_NAME  site_wp:latest   #instruction to build a image, from existing container
  #__acctid__.dkr.ecr.us-east-1.amazonaws.com/__repo__:latest   #typical URL for AWS private repo

  REPO_TAG=$(basename $OPTIONAL_PHP_IMAGE_REPO)
  echo "Saving $CONTAINER_NAME as image: $REPO_TAG"
  docker commit $CONTAINER_NAME  $REPO_TAG
  echo "uploading to: $OPTIONAL_PHP_IMAGE_REPO"
  docker tag $REPO_TAG $OPTIONAL_PHP_IMAGE_REPO
  docker push $OPTIONAL_PHP_IMAGE_REPO

  # add date tag
  REPO_NAME=$(echo $REPO_TAG|cut -d':' -f1)
  echo "adding AWS tag $NOW  to: $OPTIONAL_PHP_IMAGE_REPO"
  PHP_MANIFEST=$(aws ecr batch-get-image --repository-name $REPO_NAME --image-ids imageTag=latest --output text --query 'images[].imageManifest')
  aws ecr put-image --repository-name $REPO_NAME --image-tag $NOW --image-manifest "$PHP_MANIFEST"
  echo "if there were no error messages, the PHP image should have been uploaded to AWS"
fi
OPTIONAL_SQL_IMAGE_IMAGE=$4
if [ "$OPTIONAL_SQL_IMAGE_REPO" != "--" ]; then
  echo "Processing $OPTIONAL_SQL_IMAGE_REPO"
  #docker commit $CONTAINER_NAME  site_wp:latest
  SQLREPO_TAG=$(basename $OPTIONAL_SQL_IMAGE_REPO)
  echo "Saving $SQLCONTAINER_NAME as image $SQLREPO_TAG"
  docker commit $SQLCONTAINER_NAME  $SQLREPO_TAG
  echo "uploading to: $OPTIONAL_SQL_IMAGE_REPO"
  docker tag $SQLREPO_TAG $OPTIONAL_SQL_IMAGE_REPO
  docker push $OPTIONAL_SQL_IMAGE_REPO

  # add date tag
  SQLREPO_NAME=$(echo $SQLREPO_TAG|cut -d':' -f1)
  echo "adding AWS tag $NOW  to: $OPTIONAL_PHP_IMAGE_REPO"
  SQL_MANIFEST=$(aws ecr batch-get-image --repository-name $SQLREPO_NAME --image-ids imageTag=latest --output text --query 'images[].imageManifest')
  aws ecr put-image --repository-name $SQLREPO_NAME --image-tag $NOW --image-manifest "$PHP_MANIFEST"
  echo "if there were no error messages, the MYSQL image should have been uploaded to AWS"
fi

docker network ls | grep nginxbridge > /dev/null
if [ $? -ne 0 ]; then
  docker network create --driver=bridge nginxbridge
fi

echo done
echo "You can access your wordpress here: $LOCAL_WP_URL"
echo "please login to wordpress /wp-login.php with: $NEW_WP_ADMIN/$NEW_WP_PASSWORD"


