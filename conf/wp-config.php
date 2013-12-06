<?php

// Database
define('DB_NAME', 'yunobase');
define('DB_USER', 'yunouser');
define('DB_PASSWORD', 'yunopass');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Keys
KEYSTOCHANGE

// Prefix
$table_prefix  = 'wp_';

// i18n
define('WPLANG', 'I18NTOCHANGE');

// Debug mode
define('WP_DEBUG', false); 

// Path
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

// WordPress settings path
require_once(ABSPATH . 'wp-settings.php');
