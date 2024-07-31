use DATABASE_NAME;
update wp_options set option_value='http://192.168.137.141:8889/' where option_name='siteurl';
update wp_options set option_value='http://192.168.137.141:8889/' where option_name='home';

