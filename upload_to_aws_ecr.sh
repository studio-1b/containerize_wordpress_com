#/bin/bash


echo "Not Implemented.  This does not work right now!"
echo "Need to find a way to populate the volumes in both containers.  "
echo "They both default creating a unnamed volume, if you don't specify a location.  "
echo "So changes in the volumized directories, are ever saved in the container, and therefore any committed images"

exit 10

if [ "$1" == "" ]; then
  echo "USAGE: upload_to_aws_ecr [wordpress_php_aws_ecr_rep_url] [wordpress_mysql_aws_ecr_rep_url]"
  exit 1
fi
if [ "$2" == "" ]; then
  echo "USAGE: upload_to_aws_ecr [wordpress_php_aws_ecr_rep_url] [wordpress_mysql_aws_ecr_rep_url]"
  exit 1
fi


CONTAINER_LABEL=$(grep -o '^\s\s\$*php:$' docker-compose.yaml)
SQLCONTAINER_LABEL=$(grep -o '^\s\s\$*mysql:$' docker-compose.yaml)

CONTAINER_NAME="$(basename $WORK)_${CONTAINER_LABEL:2:-1}php_1"
SQLCONTAINER_NAME="$(basename $WORK)_${CONTAINER_LABEL:2:-1}mysql_1"


# create container image
NOW=$(date +%Y.%m.%d)
OPTIONAL_PHP_IMAGE_REPO=$1
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

OPTIONAL_SQL_IMAGE_IMAGE=$2
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





