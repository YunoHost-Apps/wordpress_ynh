## Configuration

Use the admin panel of your WordPress to configure this app.

## YunoHost specific features

* Integration with SSO does not work (automatic login of the user if previously logged on the YunoHost web portal)
  * **private mode:** Blog only accessible by YunoHost users
  * **public mode:** Visible by anyone
* Allow one user to be the administrator (set at the installation)
* Integration with [YunoHost permission](https://yunohost.org/groups_and_permissions):
  * Users rights should be managed from the [Managing groups](https://yunohost.org/en/groups_and_permissions) to give these rights:
    * `admin`: can do everything, has "super powers"
    * `editor`: can edit all the posts and pages but cannot edit the Worpdress configuration (plugins, user rights, etc)
    * `main`: can access with the "default right" (is `subscriber` right now for the package)
  * Complete list: https://wordpress.org/documentation/article/roles-and-capabilities/#summary-of-roles
  * ⚠️ Permissions defined in YunoHost take precedence over those setted in Wordpress ⚠️
    * FIXME: not sure about which has priority, need testing
* ~~Automatic update of wordpress core, plugins and themes.~~
* Allow to set up a [multisite](https://codex.wordpress.org/Glossary#Multisite) instance.

#### Multi-users support

Supported, with LDAP ~~and SSO~~.

## Limitations

* Multisite only available on subdirectories.
* As the automatic update plugin isn't working as expected, pay attention to keep your WordPress up to date from the WordPress admin panel, and not only from YunoHost admin panel. For security reason, you should control that all updates are regularly applied in WordPress admin panel as well as in YunoHost admin panel.

**Security**

Please be aware that WordPress is known for being frequently a source of security risks (https://en.wikipedia.org/wiki/WordPress#Vulnerabilities), and also as the most popular website management system it is a target for bots and attackers.
Some vulnerabilities might let an attacker breach into your WordPress, or even your YunoHost server (via privilege escalation).

Don't forget to comply with good security principles (strong password, frequent updates, don't add unknow code in your theme/extensions…). In particular, *please keep your WordPress as up-to-date as possible*.

Furthermore, you might take a look at the [Hardening Wordpress Guide](https://wordpress.org/support/article/hardening-wordpress/). You might see some benefits in the use of Wordpress security plugins.
