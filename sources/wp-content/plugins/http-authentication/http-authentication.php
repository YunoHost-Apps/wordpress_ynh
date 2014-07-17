<?php
/*
Plugin Name: HTTP Authentication
Version: 4.5
Plugin URI: http://danieltwc.com/2011/http-authentication-4-0/
Description: Authenticate users using basic HTTP authentication (<code>REMOTE_USER</code>). This plugin assumes users are externally authenticated, as with <a href="http://www.gatorlink.ufl.edu/">GatorLink</a>.
Author: Daniel Westermann-Clark
Author URI: http://danieltwc.com/
*/

require_once(dirname(__FILE__) . DIRECTORY_SEPARATOR . 'options-page.php');

class HTTPAuthenticationPlugin {
	var $db_version = 2;
	var $option_name = 'http_authentication_options';
	var $options;

	function HTTPAuthenticationPlugin() {
		$this->options = get_option($this->option_name);

		if (is_admin()) {
			$options_page = new HTTPAuthenticationOptionsPage($this, $this->option_name, __FILE__, $this->options);
			add_action('admin_init', array($this, 'check_options'));
		}

		add_action('login_head', array($this, 'add_login_css'));
		add_action('login_footer', array($this, 'add_login_link'));
		add_action('check_passwords', array($this, 'generate_password'), 10, 3);
		add_action('wp_logout', array($this, 'logout'));
		add_filter('login_url', array($this, 'bypass_reauth'));
		add_filter('show_password_fields', array($this, 'allow_wp_auth'));
		add_filter('allow_password_reset', array($this, 'allow_wp_auth'));
		add_filter('authenticate', array($this, 'authenticate'), 10, 3);
	}

	/*
	 * Check the options currently in the database and upgrade if necessary.
	 */
	function check_options() {
		if ($this->options === false || ! isset($this->options['db_version']) || $this->options['db_version'] < $this->db_version) {
			if (! is_array($this->options)) {
				$this->options = array();
			}

			$current_db_version = isset($this->options['db_version']) ? $this->options['db_version'] : 0;
			$this->upgrade($current_db_version);
			$this->options['db_version'] = $this->db_version;
			update_option($this->option_name, $this->options);
		}
	}

	/*
	 * Upgrade options as needed depending on the current database version.
	 */
	function upgrade($current_db_version) {
		$default_options = array(
			'allow_wp_auth' => false,
			'auth_label' => 'HTTP authentication',
			'login_uri' => htmlspecialchars_decode(wp_login_url()),
			'logout_uri' => remove_query_arg('_wpnonce', htmlspecialchars_decode(wp_logout_url())),
			'additional_server_keys' => '',
			'auto_create_user' => false,
			'auto_create_email_domain' => '',
		);

		if ($current_db_version < 1) {
			foreach ($default_options as $key => $value) {
				// Handle migrating existing options from before we stored a db_version
				if (! isset($this->options[$key])) {
					$this->options[$key] = $value;
				}
			}
		}
	}

	function add_login_css() {
?>
<style type="text/css">
p#http-authentication-link {
  width: 100%;
  height: 4em;
  text-align: center;
  margin-top: 2em;
}
p#http-authentication-link a {
  margin: 0 auto;
  float: none;
}
</style>
<?php
	}

	/*
	 * Add a link to the login form to initiate external authentication.
	 */
	function add_login_link() {
		global $redirect_to;

		$login_uri = $this->_generate_uri($this->options['login_uri'], wp_login_url($redirect_to));
		$auth_label = $this->options['auth_label'];

		echo "\t" . '<p id="http-authentication-link"><a class="button-primary" href="' . htmlspecialchars($login_uri) . '">Log In with ' . htmlspecialchars($auth_label) . '</a></p>' . "\n";
	}

	/*
	 * Generate a password for the user. This plugin does not require the
	 * administrator to enter this value, but we need to set it so that user
	 * creation and editing works.
	 */
	function generate_password($username, $password1, $password2) {
		if (! $this->allow_wp_auth()) {
			$password1 = $password2 = wp_generate_password();
		}
	}

	/*
	 * Logout the user by redirecting them to the logout URI.
	 */
	function logout() {
		$logout_uri = $this->_generate_uri($this->options['logout_uri'], home_url());

		wp_redirect($logout_uri);
		exit();
	}

	/*
	 * Remove the reauth=1 parameter from the login URL, if applicable. This allows
	 * us to transparently bypass the mucking about with cookies that happens in
	 * wp-login.php immediately after wp_signon when a user e.g. navigates directly
	 * to wp-admin.
	 */
	function bypass_reauth($login_url) {
		$login_url = remove_query_arg('reauth', $login_url);

		return $login_url;
	}

	/*
	 * Can we fallback to built-in WordPress authentication?
	 */
	function allow_wp_auth() {
		return (bool) $this->options['allow_wp_auth'];
	}

	/*
	 * Authenticate the user, first using the external authentication source.
	 * If allowed, fall back to WordPress password authentication.
	 */
	function authenticate($user, $username, $password) {
		$user = $this->check_remote_user();

		if (! is_wp_error($user)) {
			// User was authenticated via REMOTE_USER
			$user = new WP_User($user->ID);
		}
		else {
			// REMOTE_USER is invalid; now what?

			if (! $this->allow_wp_auth()) {
				// Bail with the WP_Error when not falling back to WordPress authentication
				wp_die($user);
			}

			// Fallback to built-in hooks (see wp-includes/user.php)
		}

		return $user;
	}

	/*
	 * If the REMOTE_USER or REDIRECT_REMOTE_USER evironment variable is set, use it
	 * as the username. This assumes that you have externally authenticated the user.
	 */
	function check_remote_user() {
		$username = '';

		$server_keys = $this->_get_server_keys();
		foreach ($server_keys as $server_key) {
			if (! empty($_SERVER[$server_key])) {
				$username = $_SERVER[$server_key];
			}
		}

		if (! $username) {
			return new WP_Error('empty_username', '<strong>ERROR</strong>: No user found in server variables.');
		}

		// Create new users automatically, if configured
		$user = get_user_by('login', $username);
		if (! $user)  {
			if ((bool) $this->options['auto_create_user']) {
				$user = $this->_create_user($username);
			}
			else {
				// Bail out to avoid showing the login form
				$user = new WP_Error('authentication_failed', __('<strong>ERROR</strong>: Invalid username or incorrect password.'));
			}
		}

		return $user;
	}

	/*
	 * Return the list of $_SERVER keys that we will check for a username. By
	 * default, these are REMOTE_USER and REDIRECT_REMOTE_USER. Additional keys
	 * can be configured from the options page.
	 */
	function _get_server_keys() {
		$server_keys = array('REMOTE_USER', 'REDIRECT_REMOTE_USER');

		$additional_server_keys = $this->options['additional_server_keys'];
		if (! empty($additional_server_keys)) {
			$keys = preg_split('/,\s*/', $additional_server_keys);
			$server_keys = array_merge($server_keys, $keys);
		}

		return $server_keys;
	}

	/*
	 * Create a new WordPress account for the specified username.
	 */
	function _create_user($username) {
		$password = wp_generate_password();
		$email_domain = $this->options['auto_create_email_domain'];

		$user_id = wp_create_user($username, $password, $username . ($email_domain ? '@' . $email_domain : ''));
		$user = get_user_by('id', $user_id);

		return $user;
	}

	/*
	 * Fill the specified URI with the site URI and the specified return location.
	 */
	function _generate_uri($uri, $redirect_to) {
		// Support tags for staged deployments
		$base = $this->_get_base_url();

		$tags = array(
			'host' => $_SERVER['HTTP_HOST'],
			'base' => $base,
			'site' => home_url(),
			'redirect' => $redirect_to,
		);

		foreach ($tags as $tag => $value) {
			$uri = str_replace('%' . $tag . '%', $value, $uri);
			$uri = str_replace('%' . $tag . '_encoded%', urlencode($value), $uri);
		}

		// Support previous versions with only the %s tag
		if (strstr($uri, '%s') !== false) {
			$uri = sprintf($uri, urlencode($redirect_to));
		}

		return $uri;
	}

	/*
	 * Return the base domain URL based on the WordPress home URL.
	 */
	function _get_base_url() {
		$home = parse_url(home_url());

		$base = home_url();
		foreach (array('path', 'query', 'fragment') as $key) {
			if (! isset($home[$key])) continue;
			$base = str_replace($home[$key], '', $base);
		}

		return $base;
	}
}

// Load the plugin hooks, etc.
$http_authentication_plugin = new HTTPAuthenticationPlugin();
?>
