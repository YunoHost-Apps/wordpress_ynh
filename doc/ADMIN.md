## Configuration

Use the admin panel of your WordPress to configure this app.

## YunoHost specific features

 * Integration with YunoHost users and SSO:
   * private mode: Blog only accessible by YunoHost users
   * public mode: Visible by anyone, YunoHost users automatically connected
 * Automatic update of wordpress core, plugins and themes.
 * Allow to set up a [multisite](https://codex.wordpress.org/Glossary#Multisite) instance.

#### Multi-users support

Supported, with LDAP and SSO.

## Limitations

* Multisite only available on subdirectories.
* As the automatic update plugin isn't working as expected, pay attention to keep your WordPress up to date from the WordPress admin panel, and not only from YunoHost admin panel. For security reason, you should control that all updates are regularly applied in WordPress admin panel as well as in YunoHost admin panel.

**Security**

Please be aware that WordPress is known for being frequently a source of security risks (https://en.wikipedia.org/wiki/WordPress#Vulnerabilities), and also as the most popular website management system it is a target for bots and attackers.
Some vulnerabilities might let an attacker breach into your WordPress, or even your YunoHost server (via privilege escalation).

Don't forget to comply with good security principles (strong password, frequent updates, don't add unknow code in your theme/extensions…). In particular, *please keep your WordPress as up-to-date as possible*.

Furthermore, you might take a look at the [Hardening Wordpress Guide](https://wordpress.org/support/article/hardening-wordpress/). You might see some benefits in the use of Wordpress security plugins.
