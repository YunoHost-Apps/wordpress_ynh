<?php

// Database
define('DB_NAME', 'yunobase');
define('DB_USER', 'yunouser');
define('DB_PASSWORD', 'yunopass');
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

// Path
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

// WordPress settings path
require_once(ABSPATH . 'wp-settings.php');

// Force https redirect
//define('FORCE_SSL_ADMIN', true);
