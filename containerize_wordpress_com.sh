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
  #< Set-Cookie: wordpress_sec_de8dbb9b84=; path=/blog/wp-content/plugins; secure; HttpOnly
  #< Set-Cookie: wordpress_sec_de8dbb9b8b98b7d=export_user%7C171755S8u7mZ%=; path=/blog/wp-admin; secure; HttpOnly
  #< Set-Cookie: wordpress_logged_in_de8dbf=export_user%7C1717553825%LS=; path=/blog/; HttpOnly
  #< Upgrade: h2,h2c
  #< Connection: Upgrade
  #< Location: https://_____.wordpress.com/wp-admin/
  #< Vary: Accept-Encoding
  #< Content-Length: 0
  #< Content-Type: text/html; charset=UTF-8
  #<
  #* Connection #0 to host _____.wordpress.com left intact
  #* Closing connection #0
  #...
  #var configData = {"env":"production","env_id":"production","favicon_url":"\2F\xs1.wp.com\x2F\xfavicon.ico","boom_analytics_enabled":true,"server_side_boom_analytics_enabled":true,"boom_analytics_key":"production","client_slug":"browser","daily_post_blog_id":37,"facebook_api_key":"90","features":{"ad-tracking":true,"akismet\x2Fcheckout-qtity-dropdown":true,"calypso\x2Fai-blogging-prompts":false,"calypso\Fi-assembler":false,"calypso\x2Fbig-sky":false,"bilmur-script":true,"calypso\x2Fhelp-center":true,"calypsoify\x2Fplugins":true,"cancellation-offers":true,"catch-js-errors":true,"checkout\xFbax-pix":true,"checkout\xgoogle-pay":true,"checkout\xva-form":true,"checkout\xcheckout-version":false,"checkout\Frazorpay":false,"cloudflare":true,"current-site\x2Fdom-warning":true,"current-site\notice":true,"current-site\x2Fste-cart-notice":false,"desktop-promo":true,"domains\x2Fgdpr-consent-page":true,"domains\x2Fkracken-ui\x2Fexact-match-filter":true,"domains\x2Fkracken-ui\x2Fpagination":true,"domains\x2Fnew-status-design":true,"external-media":true,"external-media\x2Ffree-photo-library":true,"external-media\x2Fgoogle-photos":true,"external-media\x2Fopenverse":true,"cookie-banner":true,"google-my-business":true,"help":true,"help\x2Fgpt-response":true,"hosting-overview-refinements":false,"i18n\x2Fempathy-mode":false,"i18n\x2Ftranslation-scanner":true,"importer\x2Fsite-backups":true,"importer\x2Funified":true,"importers\x2Fnewsletter":false,"importers\x2Fsubstack":true,"individual-subscriber-stats":true,"is_running_in_jetpack_site":false,"is_running_in_woo_site":false,"jetpack\x2Fagency-dashboard":true,"jetpack\x2Fai-assistant-request-limit":true,"jetpack\x2Fai-logo-generator":true,"jetpack\x2Fapi-cache":false,"jetpack\x2Fbackup-messaging-i3":true,"jetpack\x2Fbackup-restore-preflight-checks":true,"jetpack\x2Fbackup-retention-settings":true,"jetpack\x2Fcancel-through-main-flow":true,"jetpack\x2Fconcierge-sessions":false,"jetpack\x2Fconnect\x2Fmobile-app-flow":true,"jetpack\x2Ffeatures-section\x2Fatomic":true,"jetpack\x2Ffeatures-section\x2Fjetpack":true,"jetpack\x2Ffeatures-section\x2Fsimple":true,"jetpack\x2Fmagic-link-signup":true,"jetpack\x2Fmanage-simple-sites":false,"jetpack\x2Fplugin-management":false,"jetpack\x2Fpricing-add-boost-social":true,"jetpack\x2Fpricing-page-annual-only":true,"jetpack\x2Fsharing-buttons-block-enabled":false,"jetpack\x2Fsimplify-pricing-structure":false,"jetpack\x2Fsocial-plans-v1":true,"jetpack\x2Fstandalone-plugin-onboarding-update-v1":true,"jetpack-social\x2Fadvanced-plan":false,"jetpack\x2Foffer-complete-after-activation":false,"jetpack\x2Fzendesk-chat-for-logged-in-users":true,"jitms":true,"lasagna":true,"launchpad-updates":false,"launchpad\x2Fnavigator":false,"launchpad\x2Fnew-task-definition-parser":true,"launchpad\x2Fnew-task-definition-parser\x2Ffree":true,"launchpad\x2Fnew-task-definition-parser\x2Fstart-writing":true,"launchpad\x2Fnew-task-definition-parser\x2Fdesign-first":true,"launchpad\x2Fnew-task-definition-parser\x2Fvideopress":true,"launchpad\x2Fnew-task-definition-parser\x2Fbuild":true,"launchpad\x2Fnew-task-definition-parser\x2Fnewsletter":true,"launchpad\x2Fnew-task-definition-parser\x2Flink-in-bio":true,"layout\x2Fapp-banner":true,"layout\x2Fguided-tours":true,"layout\x2Fquery-selected-editor":true,"layout\x2Fsite-level-user-profile":false,"layout\x2Fsupport-article-dialog":true,"legal-updates-banner":false,"livechat_solution":true,"login\x2Fmagic-login":true,"login\x2Freact-lost-password-screen":true,"login\x2Fsocial-first":true,"mailchimp":true,"marketplace-domain-bundle":false,"marketplace-fetch-all-dynamic-products":false,"marketplace-personal-premium":false,"marketplace-reviews-notification":false,"marketplace-test":false,"me\x2Faccount-close":true,"me\x2Faccount\x2Fcolor-scheme-picker":true,"me\x2Fvat-details":true,"migration-flow\x2Fenable-migration-assistant":true,"migration-flow\x2Fintroductory-offer":true,"my-sites\x2Fadd-ons":true,"onboarding\x2Fdesign-choices":true,"onboarding\x2Fimport":true,"onboarding\x2Fimport-from-blogger":true,"onboarding\x2Fimport-from-medium":true,"onboarding\x2Fimport-from-squarespace":true,"onboarding\x2Fimport-from-wix":true,"onboarding\x2Fimport-from-wordpress":true,"onboarding\x2Fimport-redirect-to-themes":true,"onboarding\x2Finterval-dropdown":true,"onboarding\x2Ftrail-map-feature-grid-copy":false,"onboarding\x2Ftrail-map-feature-grid-structure":false,"onboarding\x2Ftrail-map-feature-grid":false,"onboarding\x2Fuser-on-stepper-hosting":false,"p2\x2Fp2-plus":true,"p2-enabled":false,"pattern-assembler\x2Fv2":true,"performance-profiler":false,"plans\x2Fhosting-trial":true,"plans\x2Fmigration-trial":true,"plans\x2Fpersonal-plan":true,"plans\x2Fpro-plan":false,"plans\x2Fstarter-plan":false,"plans\x2Fupdated-storage-labels":true,"plans\x2Fupgradeable-storage":true,"plugins\x2Fmultisite-scheduled-updates":true,"plugins\x2Fssr-categories":true,"plugins\x2Fssr-details":true,"plugins\x2Fssr-landing":true,"post-editor\x2Fcheckout-overlay":true,"post-list\x2Fqr-code-link":false,"press-this":true,"promote-post\x2Fwidget-i2":true,"publicize-preview":true,"purchases\x2Fnew-payment-methods":true,"push-notifications":true,"reader":true,"reader\x2Ffirst-posts-stream":true,"reader\x2Ffull-errors":false,"reader\x2Flist-management":true,"reader\x2Fpublic-tag-pages":true,"readymade-templates\x2Fshowcase":false,"redirect-fallback-browsers":true,"rum-tracking\x2Flogstash":true,"safari-idb-mitigation":true,"start-with\x2Fsquare-payments":true,"start-with\x2Fstripe":false,"security\x2Fsecurity-checkup":true,"seller-experience":true,"server-side-rendering":true,"settings\x2Fnewsletter-settings-page":true,"settings\x2Fsecurity\x2Fmonitor":true,"sign-in-with-apple":true,"sign-in-with-apple\x2Fredirect":true,"signup\x2Fdesign-picker-preview-colors":true,"signup\x2Fdesign-picker-preview-fonts":true,"signup\x2Fprofessional-email-step":false,"signup\x2Fsocial":true,"signup\x2Fsocial-first":true,"signup\x2Femail-subscription-flow":true,"site-indicator":true,"site-profiler\x2Fmetrics":false,"ssr\x2Flog-prefetch-errors":true,"ssr\x2Fprefetch-timebox":true,"ssr\x2Fsample-log-cache-misses":true,"stats\x2Fempty-module-traffic":true,"stats\x2Fempty-module-v2":true,"stats\x2Fpaid-wpcom-v2":true,"stats\x2Frestricted-dashboard":true,"stats\x2Fdate-picker-calendar":false,"stepper-woocommerce-poc":true,"storage-addon":true,"subscriber-csv-upload":true,"subscriber-importer":true,"subscription-gifting":true,"themes\x2Fblock-theme-previews-premium-and-woo":true,"themes\x2Fdiscovery":true,"themes\x2Fdisplay-thank-you-page-for-bundle":true,"themes\x2Fpremium":true,"themes\x2Fsubscription-purchases":false,"themes\x2Ftext-search-lots":true,"themes\x2Fassembler-first":true,"upgrades\x2Fredirect-payments":true,"upgrades\x2Fupcoming-renewals-notices":true,"upgrades\x2Fwpcom-monthly-plans":true,"use-translation-chunks":true,"user-management-revamp":true,"videomaker-trial":true,"videopress-tv":false,"woop":false,"woo\x2Fpasswordless":true,"wordpress-action-search":false,"wpcom-user-bootstrap":true,"yolo\x2Fcommand-palette":true},"google_recaptcha_site_key":false,"hotjar_enabled":true,"hostname":"wordpress.com","i18n_default_locale_slug":"en","lasagna_url":"wss:\x2F\x2Frt-api.wordpress.com\x2Fsocket","login_url":"https:\x2F\x2Fwordpress.com\x2Fwp-login.php","logout_url":"https:\x2F\x2Fwordpress.com\x2Fwp-login.php\x3Faction\x3Dlogout\x26redirect_to\x3Dhttps\x253A\x252F\x252F\x7Csubdomain\x7Cwordpress.com","wpcom_signup_url":false,"wpcom_login_url":false,"wpcom_authorize_endpoint":false,"jetpack_connect_url":false,"mc_analytics_enabled":true,
  #  "oauth_client_id":"131",
  #"protocol":"http","port":"303","jetpack_support_blog":"jetpackme.wordpress.com","wpcom_support_blog":"en.support.wordpress.com","apple_pay_merchant_id":"merchant.com.wordpress","apple_oauth_client_id":"com.wordpress.siwa","github_app_slug":"wordpress-com-for-developers","github_oauth_client_id":"Iva7aa","google_oauth_client_id":"8vrc.apps.googleusercontent.com","facebook_app_id":"23","livechat_support_locales":["en","en-gb"],"dsp_stripe_pub_key":"pk_live_51RArRsET0orrofmsyx","dsp_widget_js_src":"https:\x2F\x2Fdsp.wp.com\x2Fwidget.js","blaze_pro_back_link":"https:\x2F\x2Fdsp-pro-client.production.ingress.dca.tumblr.net\x2Fapp","advertising_dashboard_path_prefix":"\x2Fadvertising","zendesk_presales_chat_key":"216bf91d-f18","zendesk_presales_chat_key_akismet":"7ce","zendesk_presales_chat_key_jp_checkout":"7c42","zendesk_presales_chat_key_jp_agency_dashboard":false,"zendesk_support_chat_key":"cec07b4","upwork_support_locales":["de","de-at","de-li","de-lu","de-ch","es","es-cl","es-mx","fr","fr-ca","fr-be","fr-ch","it","it-ch","ja","nl","nl-be","nl-nl","pt","pt-pt","pt-br","sv","sv-fi","sv-se"],"support_site_locales":["ar","de","en","es","fr","he","id","it","ja","ko","nl","pt-br","ru","sv","tr","zh-cn","zh-tw"],"forum_locales":["ar","de","el","en","es","fa","fi","fr","id","it","ja","nl","pt","pt-br","ru","sv","th","tl","tr"],"magnificent_non_en_locales":["es","pt-br","de","fr","he","ja","it","nl","ru","tr","id","zh-cn","zh-tw","ko","ar","sv"],"jetpack_com_locales":["en","ar","de","es","fr","he","id","it","ja","ko","nl","pt-br","ro","ru","sv","tr","zh-cn","zh-tw"],"english_locales":["en","en-gb"],"readerFollowingSource":"calypso","siftscience_key":"a4f69f6759","signup_url":"\x2Fstart","woocommerce_blog_id":70,"wpcom_concierge_schedule_id":1,"wpcom_signup_id":"11",
  #  "wpcom_signup_key":"x4f6wLs"
  #,"statsd_analytics_response_time_max_logs_per_second":50,"google_maps_and_places_api_key":"AJN-ceTLP1CS","push_notification_vapid_keyi-gCsrxjxOyul28-E99CvwwJ","enable_all_sections":true,"sections":{"a8c-for-agencies":false,"a8c-for-agencies-auth":false,"a8c-for-agencies-landing":false,"a8c-for-agencies-overview":false,"a8c-for-agencies-plugins":false,"a8c-for-agencies-sites":false,"a8c-for-agencies-marketplace":false,"a8c-for-agencies-purchases":false,"a8c-for-agencies-signup":false,"a8c-for-agencies-referrals":false,"a8c-for-agencies-migrations":false,"a8c-for-agencies-settings":false,"a8c-for-agencies-partner-directory":false,"a8c-for-agencies-client":false,"jetpack-cloud":false,"jetpack-cloud-overview":false,"jetpack-cloud-agency-dashboard":false,"jetpack-cloud-agency-sites-v2":false,"jetpack-cloud-features-comparison":false,"jetpack-cloud-plugin-management":false,"jetpack-cloud-agency-signup":false,"jetpack-cloud-auth":false,"jetpack-cloud-partner-portal":false,"jetpack-cloud-pricing":false,"jetpack-cloud-manage-pricing":false,"jetpack-cloud-settings":false,"jetpack-cloud-golden-token":false,"jetpack-social":false,"jetpack-subscribers":false,"jetpack-monetize":false},"site_filter":[],"theme":"default","site_name":"WordPress.com","meta":[{"property":"og:site_name","content":"WordPress.com"}],"restricted_me_access":true,"theme_color":"","reskinned_flows":["launch-site","onboarding","onboarding-with-email","onboarding-pm","with-add-ons","newsletter","setup-site","account","do-it-for-me","do-it-for-me-store","website-design-services","desktop","developer","site-content-collection","importer","hosting","hosting-start","import","import-light","from","main","reader","simple","woocommerce-install","with-theme","with-plugin","with-theme-assembler","free","personal","personal-monthly","personal-2y","personal-3y","premium","premium-monthly","premium-2y","premium-3y","business","business-monthly","business-2y","business-3y","ecommerce","ecommerce-monthly","ecommerce-2y","ecommerce-3y","entrepreneur","pro","starter","domain","onboarding-2023-pricing-grid","domain-transfer","site-selected","guided","domain-for-gravatar","plans-first","onboarding-affiliate","email-subscription"],"bilmur_url":"\x2Fwp-content\x2Fjs\x2Fbilmur.min.js"};

  curl --header "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0" --cookie "wordpress_test_cookie=WP%20Cookie%20check" -v https://wordpress.com/log-in/ &>containerize_wordpress_com.1.tmp
  if [ $? -ne 0 ]; then
    echo "Unable to connect to login page.  Look in containerize_wordpress_com.1.tmp for error.aborting"
    exit 1
  fi
  CLIENT_ID=$(grep -o '"oauth_client_id":"[0-9a-zA-Z]*"' containerize_wordpress_com.1.tmp| cut -d\" -f4)
  CLIENT_SECRET=$(grep -o '"wpcom_signup_key":"[0-9a-zA-Z]*"' containerize_wordpress_com.1.tmp| cut -d\" -f4)
  if [ "$CLIENT_ID" == "" ]; then
    echo "unable to extract client id from wordpress website.  Did they update something?  This is HTML scraper and exxpects the variables to remain same.  Aborting"
    exit 2
  fi
  if [ "$CLIENT_SECRET" == "" ]; then
    echo "unable to extract client secret from wordpress website.  Did they update something?  This is HTML scraper and exxpects the variables to remain same.  Aborting"
    exit 2
  fi
  echo "CLIENT_ID=$CLIENT_ID"
  echo "CLIENT_SECRET=$CLIENT_SECRET"

  # {"code":200,"headers":[{"name":"Content-Type","value":"application\/json"}],"body":{"passwordless":false,"email_verified":true}}
  REST_PATH=${WP_USERNAME//@/%40}
  curl -v https://public-api.wordpress.com/rest/v1.1/users/$REST_PATH/auth-options?http_envelope=1 &>containerize_wordpress_com.2.tmp
  FOUND=$(grep -o '"code":[0-9a-zA-Z]*' containerize_wordpress_com.2.tmp| cut -d\: -f2)
  if [ "$FOUND" != "200" ]; then
    echo "unable to verify username.  Look in containerize_wordpress_com.2.tmp.  Did they update something?   Aborting"
    exit 2
  fi
  echo "JSON code for $REST_PATH = $FOUND"

  curl -v -H "Accept: application/json" -X POST "https://wordpress.com/wp-login.php?action=login-endpoint" -H "Content-Type: application/x-www-form-urlencoded" -d "username=${WP_USERNAME}&password=${WP_PASSWORD}&remember_me=true&redirect_to=${WP_URL//:\/\//%3A%2F%2F}%2Fwp-admin%2F&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&domain=&tos=%7B%22path%22%3A%22%2Flog-in%22%2C%22locale%22%3A%22en%22%2C%22viewport%22%3A%22991x937%22%7D&anon_id=fBcC18h0hTHF5bDu5QM%2F7qs%2F" --cookie "wordpress_test_cookie=WP+Cookie+check" &> containerize_wordpress_com.3.tmp
  grep '{"success":true,"data":{"redirect_to":"' containerize_wordpress_com.3.tmp &>/dev/null
  #grep -i "< Location: $WP_URL/wp-admin/" containerize_wordpress_com.3.tmp > /dev/null
  if [ $? -ne 0 ]; then
    echo "Error!  Login to wordpress website failed"
    echo "see containerize_wordpress_com.3.tmp for details"
    echo "did you supply the correct username, and have a file with same name, with password inside?"
    exit 3
  fi
  REDIRECT_URL=$(grep -o '{"success":true,"data":{"redirect_to":"[^"]*"' containerize_wordpress_com.3.tmp | cut -d\" -f8 | tr -d '\')
  if [ "$REDIRECT_URL" == ""  ]; then
    echo "Unable to find Redirect URL"
    exit 4
  fi
  echo "Visiting redirect = $REDIRECT_URL"


#< x-frame-options: SAMEORIGIN
#< set-cookie: recognized_logins=786GgYNK8Jv7ONWH1->
#< set-cookie: wordpress=username%7C11298>
#< set-cookie: wordpress=username%7C1818084%CnqNCMo>
#< set-cookie: wordpress_logged_in=username%7C1188%7>
#< p3p: CP="CAO PSA"
#< set-cookie: wordpress_sec=username%7C1120827CmqN>
#< set-cookie: wordpress_sec=username%7C118082%7nmoNr>
#< x-ac: 2.sea _bur BYPASS
  grep -i '< Set-Cookie: ' containerize_wordpress_com.3.tmp > /dev/null
  if [ $? -ne 0 ]; then
    echo "Error! Cannot find login cookie"
    echo "see containerize_wordpress_com.tmp for details"
    echo "should have: set-cookie"
    exit 4
  fi

  COOKIE_1=$(grep -io '< Set-Cookie: recognized_logins=[^;]*' containerize_wordpress_com.3.tmp | head -n 1 | cut -d' ' -f3)
  COOKIE_2=$(grep -io '< Set-Cookie: wordpress=[^;]*' containerize_wordpress_com.3.tmp | head -n 1 | cut -d' ' -f3)
  COOKIE_3=$(grep -io '< Set-Cookie: wordpress_logged_in=[^;]*' containerize_wordpress_com.3.tmp | head -n 1 | cut -d' ' -f3)
  COOKIE_4=$(grep -io '< Set-Cookie: wordpress_sec=[^;]*' containerize_wordpress_com.3.tmp | head -n 1 | cut -d' '  -f3)
  WP_COOKIE="$COOKIE_1; $COOKIE_2; $COOKIE_3; $COOKIE_4"
  curl -v --cookie "$WP_COOKIE"  $REDIRECT_URL  &>containerize_wordpress_com.4.tmp
  #curl -v   $REDIRECT_URL  &>containerize_wordpress_com.5.tmp
  #curl -v --cookie "$COOKIE_1" --cookie "$COOKIE_2" --cookie "$COOKIE_3" --cookie "$COOKIE_4"  $REDIRECT_URL  &>containerize_wordpress_com.4.tmp
  if [ $? != 0 ]; then
    echo "check redirect error in containerize_wordpress_com.4.tmp"
    exit 5
  fi

  SITE_ID=$(grep -o "blog_id: '[^']*'" containerize_wordpress_com.4.tmp | cut -d\' -f2)
  if [ "$SITE_ID" == "" ]; then
    echo "Unable to find site_id in redirect URL results: containerize_wordpress_com.4.tmp"
    exit 6
  fi
  echo "SITE_ID = $SITE_ID"
  #SITE_ID=$();


# HAR file, the wp-apy cookie value, is first encoutered oddly, in a REQUEST, not RESPONSE, but is resent as
#        "request": {
#          "method": "GET",
#          "url": "https://public-api.wordpress.com/wp-admin/rest-proxy/?v=2.0",
#          "httpVersion": "h3",
#          "headers": [
#            {
#              "name": ":authority",
#              "value": "public-api.wordpress.com"
#            },
#            {
#              "name": ":method",
#              "value": "GET"
#            },
#            {
#              "name": ":path",
#              "value": "/wp-admin/rest-proxy/?v=2.0"
#            },
#            {
#              "name": ":scheme",
#              "value": "https"
#            },
#            {
#              "name": "accept",
#              "value": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
#            },
#            {
#              "name": "accept-encoding",
#              "value": "gzip, deflate, br, zstd"
#            },
#            {
#              "name": "accept-language",
#              "value": "en-US,en;q=0.9"
#            },
#            {
#              "name": "cookie",
#              "value": "wp_api=21bdbbef5; wordpress=user1%7C88720BVy; wordpress_sec=user1%7C188720%C; wordpress_logged_in=user1%711872; wp_api_sec=user1%7C1131087pBV41Lq"
#            },
#            {
#              "name": "priority",
#              "value": "u=4, i"
#            },
#            {
#              "name": "purpose",
#              "value": "prefetch"
#            },
#            {
#              "name": "referer",
#              "value": "https://wordpress.com/"
#            },
#            {
#              "name": "sec-ch-ua",
#              "value": "\"Not)A;Brand\";v=\"99\", \"Microsoft Edge\";v=\"127\", \"Chromium\";v=\"127\""
#            },
#            {
#              "name": "sec-ch-ua-mobile",
#              "value": "?0"
#            },
#            {
#              "name": "sec-ch-ua-platform",
#              "value": "\"Windows\""
#            },
#            {
#              "name": "sec-fetch-dest",
#              "value": "empty"
#            },
#            {
#              "name": "sec-fetch-mode",
#              "value": "no-cors"
#            },
#            {
#              "name": "sec-fetch-site",
#              "value": "same-site"
#            },
#            {
#              "name": "user-agent",
#              "value": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0"
#            }
#          ],
#          "queryString": [
#            {
#              "name": "v",
#              "value": "2.0"
#            }
#          ],
#          "cookies": [
#            {
#              "name": "wp_api",
#              "value": "217db3e4",
#              "path": "/wp-admin/rest-proxy/",
#              "domain": ".public-api.wordpress.com",
#              "expires": "2024-08-17T23:06:59.180Z",
#              "httpOnly": false,
#              "secure": true,
#              "sameSite": "None"
#            },
#            {
#              "name": "wordpress",
#              "value": "user1%7C118710%7pqyT1W",
#              "path": "/wp-admin",
#              "domain": ".wordpress.com",
#              "expires": "2025-09-19T23:06:50.971Z",
#              "httpOnly": true,
#              "secure": true,
#              "sameSite": "None"
#            },
#            {
#              "name": "wordpress_sec",
#              "value": "user1%7C1137287CBV4TL",
#              "path": "/wp-admin",
#              "domain": ".wordpress.com",
#              "expires": "2025-09-19T23:06:50.971Z",
#              "httpOnly": true,
#              "secure": true,
#              "sameSite": "None"
#            },
#            {
#              "name": "wordpress_logged_in",
#              "value": "user1%7108CpqyTLqgSdK85EsIqP7",
#              "path": "/",
#              "domain": ".wordpress.com",
#              "expires": "2025-09-19T23:06:50.971Z",
#              "httpOnly": true,
#              "secure": true,
#              "sameSite": "None"
#            },
#            {
#              "name": "wp_api_sec",
#              "value": "user1%7C1818Vy4T8G5eE",
#              "path": "/",
#              "domain": ".public-api.wordpress.com",
#              "expires": "2024-08-17T23:06:59.180Z",
#              "httpOnly": true,
#              "secure": true,
#              "sameSite": "None"
#            }
#          ],
#          "headersSize": -1,
#          "bodySize": 0
#        },
# THen eventually shows up as request header
#            {
#              "name": "authorization",
#              "value": "X-WPCOOKIE 7d1b:1:https://wordpress.com"
#            },
  curl -v --cookie "$WP_COOKIE"  'https://public-api.wordpress.com/wp-admin/rest-proxy/?v=2.0' &> containerize_wordpress_com.8.tmp
  APICOOKIE_1=$(grep -io '< Set-Cookie: wp_api=[^;]*' containerize_wordpress_com.8.tmp | head -n 1 | cut -d' ' -f3)
  APICOOKIE_2=$(grep -io '< Set-Cookie: wp_api_sec=[^;]*' containerize_wordpress_com.8.tmp | head -n 1 | cut -d' ' -f3)
  if [ "$APICOOKIE_1" == "" ]; then
    echo "Did not receive a securtiy key#1 for API"
    exit 12
  fi
  if [ "$APICOOKIE_2" == "" ]; then
    echo "Did not receive a securtiy key#2 for API"
    exit 13
  fi
  echo "Received security keys for WP API"

  API_COOKIE="${WP_COOKIE}; $APICOOKIE_1; $APICOOKIE_2"
  # Authorization:X-WPCOOKIE 217bdb3b4f26526ce960f:1:https://wordpress.com
  AUTH_HEADER="authorization: X-WPCOOKIE ${APICOOKIE_1:7}:1:https://wordpress.com"
  curl -v -H "$AUTH_HEADER" --cookie "$API_COOKIE" "https://public-api.wordpress.com/rest/v1.1/me/shopping-cart/${SITE_ID}?http_envelope=1" &>containerize_wordpress_com.7.tmp
  if [ $? -ne 0 ]; then
    echo "Request to confirm API key, failed.  Is internet up?  Aborting"
    exit 14
  fi
  grep '"code":200' containerize_wordpress_com.7.tmp &>/dev/null
  if [ $? -ne 0 ]; then
    echo "Did not find valid result from API key confirmation.  Aborting"
    exit 15
  fi
  echo "WP API keys confirmed"

#{
#  "code": 200,
#  "headers": [
#    {
#      "name": "Content-Type",
#      "value": "application/json"
#    }
#  ],
#  "body": {
#    "cart_generated_at_timestamp": 172,
#    "blog_id": 1,
#    "cart_key": 1,
#    "coupon": "",
#    "is_coupon_applied": false,
#    "has_auto_renew_coupon_been_automatically_applied": false,
#    "next_domain_is_free": false,
#    "next_domain_condition": "",
#    "products": [],
#    "unmerged_products": [],
#    "total_cost": 0,
#    "currency": "USD",
#    "total_cost_integer": 0,
#    "temporary": false,
#    "tax": {
#      "location": {},
#      "display_taxes": false
#    },
#    "coupon_savings_total_integer": 0,
#    "sub_total_with_taxes_integer": 0,
#    "sub_total_integer": 0,
#    "total_tax": 0,
#    "total_tax_integer": 0,
#    "total_tax_breakdown": [],
#    "credits": 0,
#    "credits_integer": 0,
#    "allowed_payment_methods": [
#      "WPCOM_Billing_WPCOM"
#    ],
#    "terms_of_service": [],
#    "did_use_cached_taxes": true,
#    "is_gift_purchase": false,
#    "gift_details": null,
#    "messages": {
#      "errors": [],
#      "success": [],
#      "persistent_errors": []
#    }
#  }
#}



  #WP_COOKIE=$(grep -i '< Set-Cookie: ' containerize_wordpress_com.tmp | cut -d';' -f1 | cut -c15- | tr '\n' ';')
  #####curl -v $WP_URL'/wp-admin/export.php?download=true&content=all&cat=0&post_author=0&post_start_date=0&post_end_date=0&post_status=0&page_author=0&page_start_date=0&page_end_date=0&page_status=0&attachment_start_date=0&attachment_end_date=0&fl-builder-template-export-select=all&submit=Download+Export+File' --cookie "$WP_COOKIE" -o wordpress.$WP_USERNAME.xml 2>&1 | grep -i '< Content-Disposition: attachment; filename='
  curl -v -H "$AUTH_HEADER" --cookie "$API_COOKIE" -X POST  "https://public-api.wordpress.com/rest/v1.1/sites/${SITE_ID}/exports/start?http_envelope=1"  &> containerize_wordpress_com.5.tmp
  if [ $? -ne 0 ]; then
    echo "unable to start export"
    exit 7
  fi
  #{
  #  "code": 200,
  #  "headers": [
  #    {
  #      "name": "Content-Type",
  #      "value": "application/json"
  #    }
  #  ],
  #  "body": {
  #    "id": 0,
  #    "status": "running"
  #  }
  #}
  EXPORT_CODE=$(grep -o '"code":[0-9]*' containerize_wordpress_com.5.tmp | cut -d':' -f2)
  EXPORT_ID=$(grep -o '"id":[0-9]*' containerize_wordpress_com.5.tmp | cut -d':' -f2)
  EXPORT_STATUS=$(grep -o '"status":"[^"]*' containerize_wordpress_com.5.tmp | cut -d\" -f4)
  echo "export start return code is [$EXPORT_CODE]... Good code =200"
  echo "export is [$EXPORT_STATUS]... EXPORT_ID=$EXPORT_ID"

  while [ "$EXPORT_STATUS" == "running" ]; do
    sleep 3
    curl -v -H "$AUTH_HEADER" --cookie "$API_COOKIE"  "https://public-api.wordpress.com/rest/v1.1/sites/${SITE_ID}/exports/${EXPORT_ID}?http_envelope=1" &>containerize_wordpress_com.6.tmp
    #{
    #  "code": 200,
    #  "headers": [
    #    {
    #      "name": "Content-Type",
    #      "value": "application/json"
    #    }
    #  ],
    #  "body": {
    #    "status": "finished",
    #    "attachment_lifetime_days": 7,
    #    "attachment_url": "https://exports.wordpress.com/wp-content/uploads/2024/08/XXXX.wordpress.com-2024-08-14-00_27_12-usqzlnsivfjpyvvtdlturjdf.zip"
    #  }
    #}
    EXPORT_STATUS=$(grep -o '"status":"[^"]*' containerize_wordpress_com.6.tmp | cut -d\" -f4)
    echo "export is [$EXPORT_STATUS]... EXPORT_ID=$EXPORT_ID"
  done
  if [ "$EXPORT_STATUS" != "finished" ]; then
    echo "export seems to have failed: $EXPORT_STATUS"
    exit 8
  fi
  EXPORT_URL=$(grep -o '"attachment_url":"[^"]*' containerize_wordpress_com.6.tmp | cut -d\" -f4 | tr -d '\')
  if [ "$EXPORT_URL" == "" ]; then
    echo "unable to find export: containerize_wordpress_com.6.tmp"
    exit 9
  fi
  echo "Getting export WXL URL: $EXPORT_URL"


  #https://exports.wordpress.com/wp-content/uploads/2024/08/car.wordpress.com-2024-08-14-00_27_12-usszmlsifmpvvtd1lyurf.zip
  #This is received from the REST loop
  FILENAME=$(basename $WP_URL)
  TAR_FILE=$FILENAME.tar
  WXL_FILE=$FILENAME.xml
  if [ "${EXPORT_URL: -4}" == ".zip" ]; then
    curl -v -H "$AUTH_HEADER" --cookie "$API_COOKIE"   $EXPORT_URL -o ${WXL_FILE}.zip
    if [ $? -ne 0 ]; then
      echo "Unable to download WXL zip"
      exit 10
    fi
    #Archive:  car.wordpress.com.xml.zip
    #    testing: car.wordpress.com-2024-08-16-22_03_50/   OK
    #    testing: car.wordpress.com-2024-08-16-22_03_50/car.wordpress.2024-08-16.000.xml   OK
    #No errors detected in compressed data of car.wordpress.com.xml.zip.
    unzip -q ${WXL_FILE}.zip
    for s in $(unzip -t ${WXL_FILE}.zip 2>&1 | grep -o 'testing: \S\S*' | cut -d' ' -f2); do
      echo "checking if [$s] is WXL export"
      if [ -f $s ]; then
        echo "is file"
        echo "${s: -4} .xml"
        if [ "${s: -4}" == ".xml" ]; then
          mv -v $s ./${WXL_FILE}
        fi
      fi
    done
  else
    curl -v -H "$AUTH_HEADER" --cookie "$API_COOKIE"   $EXPORT_URL -o ${WXL_FILE}
    if [ $? -ne 0 ]; then
      echo "Unable to download WXL"
      exit 11
    fi
  fi




  #below is download media
  # "https://public-api.wordpress.com/rest/v1.1/sites/19050/exports/media?_envelope=1&http_envelope=1"
  curl -v -H "$AUTH_HEADER" --cookie "$API_COOKIE"   "https://public-api.wordpress.com/rest/v1.1/sites/${SITE_ID}/exports/media?_envelope=1&http_envelope=1" &>containerize_wordpress_com.30.tmp
  if [ $? -ne 0 ]; then
    echo "Unable to make request for media export.  Aborting"
    exit 31
  fi

  # "text": "{\"code\":200,\"headers\":[{\"name\":\"Content-Type\",\"value\":\"application\\/json\"}],\"body\":{\"media_export_url\":\"https:\\/\\/public-api.wordpress.com\\/rest\\/v1.1\\/sites\\/1050\\/exports\\/media-download?to=56&ts=1723771109&key=7464b26005378aeb32a\"}}"
  MEDIA_URL=$(grep -o '\"media_export_url\":\"[^"]*' containerize_wordpress_com.30.tmp | cut -d\" -f4 | tr -d '\')
  if [ "$MEDIA_URL" == "" ]; then
    echo "Unable to find URL for media download.  Abrting"
    exit 32
  fi
  echo "Downloading media export URL: $MEDIA_URL"

  echo downloading media...
  #curl  "https://public-api.wordpress.com/rest/v1.1/sites/${SITE_ID}/exports/media-download?to=56&ts=1723595190&key=d5f6496d" -o $TAR_FILE

  #EPOCH=$(date +"%s") # date in standard integer format
  #curl -v -H "$AUTH_HEADER" --cookie "$API_COOKIE"   "https://public-api.wordpress.com/rest/v1.1/sites/${SITE_ID}/exports/media-download?to=99999&ts=${EPOCH}&key=d456fd64b9e44c7669d812d1a291038d" -o $TAR_FILE

  curl -v -H "$AUTH_HEADER" --cookie "$API_COOKIE"   $MEDIA_URL -o $TAR_FILE
  #Content-Disposition: attachment; filename="media-export-10-from-0-to-14056.tar"
  if [ $? -ne 0 ]; then
    echo "unable to download media export"
    exit 12
  fi

  ls -l *.tar *.xml
  echo "finished download part"
  #exit



  #======== HTML scraping, done=================
  #========Above is the spliced part from dl_wpcom_export.sh===============
  if [ ! -f "$WXL_FILE" ]; then
    echo "ERROR!  cannot find WXL export file"
    exit 6
  fi
  echo "WXL export file is: $WXL_FILE"

  if [ ! -f "$TAR_FILE" ]; then
    echo "ERROR!  cannot find media export file"
    exit 6
  fi
  echo "TAR export file is: $TAR_FILE"
fi
#===========Below, is container start, and running import in container=============



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
CONTAINER_PREFIX="${CONTAINER_PREFIX:0:25}"
echo "Using $CONTAINER_PREFIX as container name"
USED_LOCAL_PORTS=$(docker ps --format '{{.Ports}}' | grep -o  :[0-9]*-)
NEW_PORT=8888
echo $USED_LOCAL_PORTS | grep ":${NEW_PORT}-" &>/dev/null
while [ $? -eq 0 ];do
  echo "$NEW_PORT : is unavailable on this host"
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
echo "s/prefix/${CONTAINER_PREFIX}/g;s/HOST_PORT/$NEW_PORT/g"
sed "s/prefix/${CONTAINER_PREFIX}/g;s/HOST_PORT/$NEW_PORT/g" docker-compose.yaml
echo "Does this look right? (y/n)"
read DELAY
if [ "$DELAY" != "y" ]; then
  echo "aborted!"
  exit 4
fi
sed -i "s/prefix/${CONTAINER_PREFIX}/g;s/HOST_PORT/$NEW_PORT/g" docker-compose.yaml
echo "changes made to docker-compose.yaml"

#docker-compose -d up
echo "starting wordpress containers"
docker pull wordpress:latest
docker pull mysql:latest
docker-compose up -d

WORK=$(pwd)
CONTAINER_NAME="$(basename $WORK)_${CONTAINER_PREFIX}_php_1"
docker ps -f name=$CONTAINER_NAME | grep "$CONTAINER_NAME"
if [ $? -ne 0 ]; then
  echo "This script won't work"
  echo "It is expecting the new container for wordpress to be named: $CONTAINER_NAME"
  exit 1
fi
SQLCONTAINER_NAME="$(basename $WORK)_${CONTAINER_PREFIX}_mysql_1"
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
  curl -v http://localhost:$NEW_PORT &> wordpress.html
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
grep "Location: http://localhost:$NEW_PORT/wp-admin/install.php" wordpress.html
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
LOCAL_WP_URL="$(hostname):$NEW_PORT"
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
#USE=$(grep 'MYSQL_DATABASE: ' docker-compose.yaml|cut -d: -f2)
#USR=$(grep 'MYSQL_USER: ' docker-compose.yaml|cut -d: -f2)
#PWD=$(grep 'MYSQL_PASSWORD: ' docker-compose.yaml|cut -d: -f2)
#if [ ! -f update_url.sql.original ]; then
#  cp -f update_url.sql update_url.sql.original
#fi
#cp -f update_url.sql.original update_url.sh
#sed -i "s/DATABASE_NAME/${USE}/g" update_url.sql
#docker exec -i $SQLCONTAINER_NAME mysql -u $USR -p$PWD < update_url.sql




echo done
echo "You can access your wordpress here: $LOCAL_WP_URL"
echo "please login to wordpress /wp-login.php with: $NEW_WP_ADMIN/$NEW_WP_PASSWORD"

#===================================
