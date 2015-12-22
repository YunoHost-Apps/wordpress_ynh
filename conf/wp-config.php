<?php

// Database
define('DB_NAME', '__DB_USER__');
define('DB_USER', '__DB_USER__');
define('DB_PASSWORD', '__DB_PWD__');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Keys
define('AUTH_KEY',         'KEY1');
define('SECURE_AUTH_KEY',  'KEY2');
define('LOGGED_IN_KEY',    'KEY3');
define('NONCE_KEY',        'KEY4');
define('AUTH_SALT',        'KEY5');
define('SECURE_AUTH_SALT', 'KEY6');
define('LOGGED_IN_SALT',   'KEY7');
define('NONCE_SALT',       'KEY8');

// Prefix
$table_prefix  = 'wp_';

// Debug mode
define('WP_DEBUG', false); 

// Multisite
//--MULTISITE1--define('WP_ALLOW_MULTISITE', true);
//--MULTISITE2--define('MULTISITE', true);
//--MULTISITE2--define('SUBDOMAIN_INSTALL', false);
//--MULTISITE2--define('DOMAIN_CURRENT_SITE', '__DOMAIN__');
//--MULTISITE2--define('PATH_CURRENT_SITE', '__PATH__/');
//--MULTISITE2--define('SITE_ID_CURRENT_SITE', 1);
//--MULTISITE2--define('BLOG_ID_CURRENT_SITE', 1);

// Path
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

// WordPress settings path
require_once(ABSPATH . 'wp-settings.php');

// Force https redirect
//--PUBLIC--define('FORCE_SSL_ADMIN', true);
