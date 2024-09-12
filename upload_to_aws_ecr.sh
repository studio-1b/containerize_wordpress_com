#/bin/bash

if [ "$1" == "" ]; then
  echo "USAGE: upload_to_docker_hub.sh [username] [wp_data_awsrepotag]"
  exit 1
fi
if [ "$2" == "" ]; then
  echo "USAGE: upload_to_docker_hub.sh [username] [wp_data_awsrepotag]"
  exit 1
fi
echo $2 | grep ':' &>/dev/null
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
echo $2 | grep '/' &>/dev/null
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
CONTAINER_LABEL=${CONTAINER_LABEL:2:-1}
CONTAINER_LABEL=${CONTAINER_LABEL:0:25}
CONTAINER_NAME="$(basename $WORK)_${CONTAINER_LABEL}_php_1"
CONTAINER_VOL="$(basename $WORK)_${CONTAINER_LABEL}_php"

SQLCONTAINER_LABEL=$(grep -o '^\s\s\S*mysql:$' docker-compose.yaml)
SQLCONTAINER_LABEL=${SQLCONTAINER_LABEL:2:-1}
SQLCONTAINER_LABEL=${SQLCONTAINER_LABEL:0:25}
SQLCONTAINER_NAME="$(basename $WORK)_${SQLCONTAINER_LABEL}_mysql_1"
SQLCONTAINER_VOL="$(basename $WORK)_${SQLCONTAINER_LABEL}_mysql"


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

docker volume ls  | grep $CONTAINER_VOL &>/dev/null
if [ $? -ne 0 ]; then
  echo "Can't find vol $CONTAINER_VOL"
  exit 3
fi
docker volume ls | grep $SQLCONTAINER_VOL &>/dev/null
if [ $? -ne 0 ]; then
  echo "Can't find vol $SQLCONTAINER_VOL"
  exit 3
fi

REPO_TAG=$2
LOCAL_TAG=$(basename $REPO_TAG|cut -d':' -f1)
BAKCONTAINER_NAME="${LOCAL_TAG}-running"
#docker run -it --mount source=containerize_wordpress_com_whenthefoodbowlattacks-wo_php,destination=/mnt/vol1 --mount source=containerize_wordpress_com_whenthefoodbowlattacks-wo_mysql,destination=/mnt/vol2 volume_7z_alpine:latest
echo "docker run -it --name $BAKCONTAINER_NAME --mount source=$CONTAINER_VOL,destination=/mnt/vol1 --mount source=$SQLCONTAINER_VOL,destination=/mnt/vol2 volume_7z_alpine:latest"
docker run -it --name $BAKCONTAINER_NAME --mount source=$CONTAINER_VOL,destination=/mnt/vol1 --mount source=$SQLCONTAINER_VOL,destination=/mnt/vol2 car2graphy/volume_7z_alpine:latest



# create container image
NOW=$(date +%Y.%m.%d)
BACKUP_IMAGE_TAG=$2
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 166053251688.dkr.ecr.us-east-1.amazonaws.com
if [ "$BACKUP_IMAGE_TAG" != "--" ]; then
  echo "Processing $BACKUP_IMAGE_TAG"

  #docker build --progress=plain -t site_wp .      #instruction to build a image from a Dockerfile
  #docker commit $CONTAINER_NAME  site_wp:latest   #instruction to build a image, from existing container
  #__acctid__.dkr.ecr.us-east-1.amazonaws.com/__repo__:latest   #typical URL for AWS private repo

  echo "Saving $BAKCONTAINER_NAME as image: $LOCAL_TAG"
  docker commit $BAKCONTAINER_NAME $LOCAL_TAG
  if [ $? -ne 0 ]; then
    echo commit failed
    exit 1
  fi
  echo "uploading to: $OPTIONAL_PHP_IMAGE_REPO"
  docker tag $LOCAL_TAG $REPO_TAG
  docker push $REPO_TAG

  # add date tag
  REPO_NAME=$(echo $REPO_TAG|cut -d':' -f1)
  echo "adding AWS tag $NOW  to: $OPTIONAL_PHP_IMAGE_REPO"
  PHP_MANIFEST=$(aws ecr batch-get-image --repository-name $REPO_NAME --image-ids imageTag=latest --output text --query 'images[].imageManifest')
  aws ecr put-image --repository-name $REPO_NAME --image-tag $NOW --image-manifest "$PHP_MANIFEST"

  echo "if there were no error messages, the Backup image should have been uploaded to Dockerhub"
fi
