use DATABASE_NAME;
update wp_options set option_value='http://hostname/' where option_name='siteurl';
update wp_options set option_value='http://hostname/' where option_name='home';
update wp_posts set post_content=replace(post_content,"http://hostname/","http://oldurl/")  where locate(post_content, CONVERT(CAST('http://oldurl/' as BINARY) USING utf8mb4))>=0;
