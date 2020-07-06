# Wordpress for YunoHost

[![Integration level](https://dash.yunohost.org/integration/wordpress.svg)](https://dash.yunohost.org/appci/app/wordpress) ![](https://ci-apps.yunohost.org/ci/badges/wordpress.status.svg) [![](https://ci-apps.yunohost.org/ci/badges/wordpress.maintain.svg)](https://github.com/YunoHost/Apps/#what-to-do-if-i-cant-maintain-my-app-anymore-)  
[![Install Wordpress with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=wordpress)

*[Lire ce readme en français.](./README_fr.md)*

> *This package allow you to install Wordpress quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview
WordPress is open source software you can use to create a beautiful website, blog, or app.  
With this package, you can even activate the [multisite](https://codex.wordpress.org/Glossary#Multisite) option.

**Shipped version:** 5.4

## Screenshots

![](https://s.w.org/images/home/screen-themes.png?1)

## Configuration

Use the admin panel of your Wordpress to configure this app.

## Documentation

 * Official documentation: https://codex.wordpress.org/
 * YunoHost documentation: There no other documentations, feel free to contribute.

## YunoHost specific features

 * Integration with YunoHost users and SSO:
   * private mode: blog only accessible by YunoHost users
   * public mode: visible by anyone, YunoHost users automatically connected
 * Automatic update of Wordpress core, plugins and themes.
 * Allow to set up a [multisite](https://codex.wordpress.org/Glossary#Multisite) instance.

#### Multi-users support

Supported, with LDAP and SSO.

#### Supported architectures

* x86-64 - [![](https://ci-apps.yunohost.org/ci/logs/wordpress%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/wordpress/)
* ARMv8-A - [![](https://ci-apps-arm.yunohost.org/ci/logs/wordpress%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/wordpress/)
* Buster x86-64b - [![](https://ci-buster.nohost.me/ci/logs/wordpress%20%28Apps%29.svg)](https://ci-buster.nohost.me/ci/apps/wordpress/)

## Limitations

* Multisite only available on subdirectories.
* As the automatic update plugin isn't working as expected, pay attention to keep your Wordpress up to date from the Wordpress admin panel, and not only from YunoHost admin panel. For security reason, you should control that all updates are regularly applied in Wordpress admin panel as well as in yunohost admin panel.

**Security**

Please be aware that Wordpress is known for being frequently a source of security risks (https://en.wikipedia.org/wiki/WordPress#Vulnerabilities), and also as the most popular website management system it is a target for bots and attackers.
Some vulnerabilities might let an attacker breach into your Wordpress, or even your Yunohost server (via privilege escalation).

Don't forget to comply with good security principles (strong password, frequent updates, don't add unknow code in your theme/extensions...). In particular, *please keep your Wordpress as up-to-date as possible*.

Furthermore, you might take a look at this guide: https://codex.wordpress.org/Hardening_WordPress. You might see some benefits in the use of Wordpress security plugins.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/wordpress_ynh/issues
 * Wordpress website: https://wordpress.org/
 * Wordpress repository: https://core.trac.wordpress.org/browser  
 https://build.trac.wordpress.org/browser
 * YunoHost website: https://yunohost.org/

---

Developers infos
----------------

Please do your pull request to the [testing branch](https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
or
sudo yunohost app upgrade wordpress -u https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
```
