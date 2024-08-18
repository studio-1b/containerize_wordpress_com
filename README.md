# containerize_wordpress_com
Hack to call wordpress.com site's export, and containerize content in local machine.

## Requirements
Docker
Docker-compose

To install these on debian based system, run:
```
sudo apt install docker docker-compose
```

## Instructions
> [!WARNING]
> I am not affiliated with Automatic nor Wordpress.com.  Use any of these scripts at your own risk!

> [!WARNING]
> This is for copying YOUR site from the managed site "Wordpress.com".  "Wordpress.com" is a free service where you get to create your own free Wordpress website.  It is NOT "Wordpress software for Linux".  If you don't know the difference, please stop.
> If you need similar functionality for automating downloading WXL export file for "Wordpress software for Linux", please see [https://github.com/studio-1b/call_wordpress_web_export](https://github.com/studio-1b/call_wordpress_web_export) for bash script that automates downloading of WXL export using HTML scraping for Wordpress software for Linux.  

1. Install the software above, on the host computer, you wish to have a copy of your wordpress.com site.

2. Copy these shell scripts which automates the steps of downloading the exports, and creating the container, and importing.  You can do everything manually step by step in the script, if you wish.  First download these scripts:
```
git clone https://github.com/studio-1b/containerize_wordpress_com.git
cd containerize_wordpress_com
```

3. To rebuild a of copy Wordpress.com site on your own machine on "Wordpress software for Linux", you need a 1) media TAR file, and a 2) WXL export.  Your Wordpress.com site should have a URL like "http://mysite.wordpress.com", where "mysite" you selected when you created your site on their website.  You should have a username for accessing this site, when creating new posts.  It is usually your email address.  So you need:
* Your wordpress.com URL, ie. https://XXXX.wordpress.com
* Your username and password for https://XXXX.wordpress.com/wp-login.php
Save your username and password, by typing this command, which creates a file named your username, and inside has your Wordpress.com password
```
echo "[password]" > "[username]"
```
The scripts reads this file, to get your export.  It needs to "login" first.

4. Optional step: You can skip this step.  Or you can just download the exports first, or download the manually.  
* A. To download both exports manually, read https://wordpress.com/support/export/ and read https://wordpress.com/support/export-your-media-library/.  You need to read both, to download both.  When they are downloaded, you need to extract the .xml file from the zip, and rename them mysite.wordpress.com.xml and rename the .tar media export to mysite.wordpress.com.tar
* B. OR You can use the "dl_wpcom_export.sh" script, which automates a HTML-scrape, to download both files to your host.  The HTML scrap may change at anytime, so it might stop working, if they change anything.  If you want to try, execute this command:
```
./dl_wpcom_export.sh [https://<yoursite>.wordpress.com] [username]
```
And it will create several .tmp files, then download the .zip file which contains the WXL file.  It will extract and rename the WXL .xml file.  It will then download the media TAR file, which being a few gigabytes, will take a while.  And you should see 2 new files: "<yoursite>.wordpress.com.xml" and "<yoursite>.wordpress.com.tar"

5. If you ran the export above, in step 4.  Manually or via the "dl_wpcom_export.sh" script, you can just create the new Wordpress Docker containers, using the command below, with only URL, NO USERNAME:
```
containerize_wordpress_com.sh [wordpress.com url]
```
If the script sees 1 argument, it will assume that argument looks like "https://<mysite>.wordpress.com" AND you have 2 files named: "<mysite>.wordpress.com.xml" and "<mysite>.wordpress.com.tar".  And it will skip downloading the exports from internet, and create the containers using those exports.

OR to BOTH DOWNLOAD NEW EXPORTS FROM Wordpress.com, and also create a container that imports the data, run:
```
containerize_wordpress_com.sh [wordpress.com url] [wordpress.com username]
```
It will read the file with your username, login to the wordpress.com URL you provided, with the password in the file, and it will download both exports, then try to create the Wordpress containers on the host, and import the content.


# Result
It should 
1. create 1 container for PHP, which contains the wordpress PHP files
2. and create 1 container for MYSQL, which contains the wordpress MYSQL tables
3. and it will import all your files into wordpress in both MYSQL and PHP containers
4. and direct a host port, to the PHP website, so you can view your data

## Caveats
This is untested code, as of 7/30/24.  The individual commands are correct, but I haven't tested it for bugs, and error handling.  Please use at your own risk.
