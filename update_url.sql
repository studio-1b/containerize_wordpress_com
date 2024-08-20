use DATABASE_NAME;
update wp_options set option_value='http://hostname/' where option_name='siteurl';
update wp_options set option_value='http://hostname/' where option_name='home';

