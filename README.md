# containerize_wordpress_com
Hack to call wordpress.com site's export, and containerize content in local machine.

## Requirements
Docker
Docker-compose
on debian based system
```
sudo apt install docker docker-compose
```
If you want to use the image upload to AWS feature, you need 
AWS ECR repositories for
- PHP-image
- mysql-image

## Instructions
To just create a container, from wordpress, run:
```
containerize_wordpress_com.sh [wordpress.com url] [wordpress.com username]
```

To create a container, then upload the resulting image, into AWS ECR repository
```
containerize_wordpress_com.sh [wordpress.com url] [wordpress username] [URL for AWS ECR private repo, for PHP] [URL for AWS ECR private repo, for mysql]
```

# result
it should create 1 container for PHP, which contains the wordpress PHP files
and create 1 container for MYSQL, which contains the wordpress MYSQL tables
and it will import all your files into wordpress in both MYSQL and PHP containers
and direct a host port, to the PHP website, so you can view your data

## Caveats
This is untested code, as of 7/30/24.  The individual commands are correct, but I haven't tested it for bugs, and error handling.  Please use at your own risk.
