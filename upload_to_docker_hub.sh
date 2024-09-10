#/bin/bash

if [ "$1" == "" ]; then
  echo "USAGE: upload_to_docker_hub.sh [username] [wp_php_tag] [wp_mysql_tag]"
  exit 1
fi
if [ "$2" == "" ]; then
  echo "USAGE: upload_to_docker_hub.sh [username] [wp_php_tag] [wp_mysql_tag]"
  exit 1
fi
if [ "$3" == "" ]; then
  echo "USAGE: upload_to_docker_hub.sh [username] [wp_php_tag] [wp_mysql_tag]"
  exit 1
fi
echo $1 | grep ':' &>/dev/null
if [ $? -eq 0 ]; then
  #https://stackoverflow.com/questions/55277250/what-are-the-appropriate-names-for-the-parts-of-a-docker-images-name#:~:text=According%20to%20the%20reference%20for,my%2Dregistry%20is%20the%20registry
  echo "Found ':' in parameters"
  echo "Please only enter image name for PHP argument, not with tag suffix: $1"
  echo "Example:"
  echo "my-registry/my-image:0.1.0"
  echo "my-registry is the registry"
  echo "my-registry/my-image is the (image) name"
  echo "0.1.0 is the tag (name)"
  echo "[NO ] my-registry/my-image:0.1.0"
  echo "[NO ] my-registry is the registry"
  echo "[NO ] my-registry/my-image is the (image) name"
  echo "[NO ] 0.1.0 is the tag (name)"
  echo "[YES] my-image"
  exit 1
fi
echo $2 | grep ':' &>/dev/null
if [ $? -eq 0 ]; then
  #https://stackoverflow.com/questions/55277250/what-are-the-appropriate-names-for-the-parts-of-a-docker-images-name#:~:text=According%20to%20the%20reference%20for,my%2Dregistry%20is%20the%20registry
  echo "Found ':' in parameters"
  echo "Please only enter image name for MYSQL argument, not with tag suffix: $2"
  echo "Example:"
  echo "my-registry/my-image:0.1.0"
  echo "my-registry is the registry"
  echo "my-registry/my-image is the (image) name"
  echo "0.1.0 is the tag (name)"
  echo "[NO ] my-registry/my-image:0.1.0"
  echo "[NO ] my-registry is the registry"
  echo "[NO ] my-registry/my-image is the (image) name"
  echo "[NO ] 0.1.0 is the tag (name)"
  echo "[YES] my-image"
  exit 1
fi
echo $1 | grep '/' &>/dev/null
if [ $? -eq 0 ]; then
  #https://stackoverflow.com/questions/55277250/what-are-the-appropriate-names-for-the-parts-of-a-docker-images-name#:~:text=According%20to%20the%20reference%20for,my%2Dregistry%20is%20the%20registry
  echo "Found '/' in parameters"
  echo "Please only enter image name for PHP argument, not with tag suffix: $1"
  echo "Example:"
  echo "my-registry/my-image:0.1.0"
  echo "my-registry is the registry"
  echo "my-registry/my-image is the (image) name"
  echo "0.1.0 is the tag (name)"
  echo "[NO ] my-registry/my-image:0.1.0"
  echo "[NO ] my-registry is the registry"
  echo "[NO ] my-registry/my-image is the (image) name"
  echo "[NO ] 0.1.0 is the tag (name)"
  echo "[YES] my-image"
  exit 1
fi
echo $2 | grep '/' &>/dev/null
if [ $? -eq 0 ]; then
  #https://stackoverflow.com/questions/55277250/what-are-the-appropriate-names-for-the-parts-of-a-docker-images-name#:~:text=According%20to%20the%20reference%20for,my%2Dregistry%20is%20the%20registry
  echo "Found '/' in parameters"
  echo "Please only enter image name for MYSQL argument, not with tag suffix: $2"
  echo "Example:"
  echo "my-registry/my-image:0.1.0"
  echo "my-registry is the registry"
  echo "my-registry/my-image is the (image) name"
  echo "0.1.0 is the tag (name)"
  echo "[NO ] my-registry/my-image:0.1.0"
  echo "[NO ] my-registry is the registry"
  echo "[NO ] my-registry/my-image is the (image) name"
  echo "[NO ] 0.1.0 is the tag (name)"
  echo "[YES] my-image"
  exit 1
fi

#login to docker hub repo
USERNAME=$1
PASSWORD_FILE="${USERNAME}@dockerhub"
if [ ! -f "$PASSWORD_FILE" ]; then
  echo "ERROR: there must be a file named '${PASSWORD_FILE}' with docker hub password as contents"
  exit 2
fi
cat $PASSWORD_FILE | docker login --username $USERNAME --password-stdin


# get relevant containers for wordpress
WORK=$(pwd)
CONTAINER_LABEL=$(grep -o '^\s\s\S*php:$' docker-compose.yaml)
SQLCONTAINER_LABEL=$(grep -o '^\s\s\S*mysql:$' docker-compose.yaml)

CONTAINER_LABEL=${CONTAINER_LABEL:2:-1}
SQLCONTAINER_LABEL=${SQLCONTAINER_LABEL:2:-1}

CONTAINER_LABEL=${CONTAINER_LABEL:0:25}
SQLCONTAINER_LABEL=${SQLCONTAINER_LABEL:0:25}


CONTAINER_NAME="$(basename $WORK)_${CONTAINER_LABEL}_php_1"
SQLCONTAINER_NAME="$(basename $WORK)_${SQLCONTAINER_LABEL}_mysql_1"

docker ps  | grep $CONTAINER_NAME &>/dev/null
if [ $? -ne 0 ]; then
  echo "Can't find $CONTAINER_NAME"
  exit 3
fi
docker ps  | grep $SQLCONTAINER_NAME &>/dev/null
if [ $? -ne 0 ]; then
  echo "Can't find $SQLCONTAINER_NAME"
  exit 3
fi

# create container image
NOW=$(date +%Y.%m.%d)
OPTIONAL_PHP_IMAGE_TAG=$2
if [ "$OPTIONAL_PHP_IMAGE_TAG" != "--" ]; then
  echo "Processing $OPTIONAL_PHP_IMAGE_TAG"

  LOCAL_TAG=$OPTIONAL_PHP_IMAGE_TAG
  echo "Saving $CONTAINER_NAME as image: $LOCAL_TAG"
  docker commit $CONTAINER_NAME  $LOCAL_TAG

  REPO_TAG="$USERNAME/${LOCAL_TAG}:latest"
  echo "uploading to: Docker $REPO_TAG"
  docker image tag $LOCAL_TAG  $REPO_TAG
  docker image push $REPO_TAG
  #docker tag $REPO_TAG $OPTIONAL_PHP_IMAGE_REPO
  #docker push $OPTIONAL_PHP_IMAGE_REPO

  # add date tag
  echo "adding tag $NOW  to: $REPO_TAG"
  DATE_REPO_TAG="$USERNAME/${LOCAL_TAG}:$NOW"
  docker image tag $REPO_TAG $DATE_REPO_TAG
  docker image push $DATE_REPO_TAG

  echo "if there were no error messages, the PHP image should have been uploaded to Dockerhub"
fi

OPTIONAL_SQL_IMAGE_TAG=$3
if [ "$OPTIONAL_SQL_IMAGE_TAG" != "--" ]; then
  echo "Processing $OPTIONAL_SQL_IMAGE_TAG"
  #docker commit $CONTAINER_NAME  site_wp:latest
  #SQLREPO_TAG=$(basename $OPTIONAL_SQL_IMAGE_REPO)

  SQLLOCAL_TAG=$OPTIONAL_SQL_IMAGE_TAG
  echo "Saving $CONTAINER_NAME as image: $SQLLOCAL_TAG"
  docker commit $SQLCONTAINER_NAME  $SQLLOCAL_TAG

  SQLREPO_TAG="$USERNAME/${SQLLOCAL_TAG}:latest"
  echo "uploading to: Docker $SQLREPO_TAG"
  docker image tag $SQLLOCAL_TAG  $SQLREPO_TAG
  docker image push $SQLREPO_TAG
  #docker tag $REPO_TAG $OPTIONAL_PHP_IMAGE_REPO
  #docker push $OPTIONAL_PHP_IMAGE_REPO

  # add date tag
  echo "adding tag $NOW  to: $SQLREPO_TAG"
  DATE_SQLREPO_TAG="$USERNAME/${SQLLOCAL_TAG}:$NOW"
  docker image tag $SQLREPO_TAG $DATE_SQLREPO_TAG
  docker image push $DATE_SQLREPO_TAG

  echo "if there were no error messages, the MYSQL image should have been uploaded to Dockerhub"
fi





