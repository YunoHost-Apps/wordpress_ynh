# Wordpress pour YunoHost

[![Integration level](https://dash.yunohost.org/integration/wordpress.svg)](https://dash.yunohost.org/appci/app/wordpress) ![](https://ci-apps.yunohost.org/ci/badges/wordpress.status.svg) [![](https://ci-apps.yunohost.org/ci/badges/wordpress.maintain.svg)](https://github.com/YunoHost/Apps/#what-to-do-if-i-cant-maintain-my-app-anymore-)  
[![Installer Wordpress avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=wordpress)

*[Read this readme in english.](./README.md)* 

> *Ce package vous permet d'installer Wordpress rapidement et simplement sur un serveur YunoHost.  
Si vous n'avez pas YunoHost, consultez [le guide](https://yunohost.org/#/install) pour apprendre comment l'installer.*

## Vue d'ensemble
WordPress est un logiciel open source que vous pouvez utiliser pour créer un beau site Web, blog ou application.
Avec ce package, vous pouvez activer l'option [multisite](https://codex.wordpress.org/Glossary#Multisite).

**Version incluse :** 5.4

## Captures d'écran

![](https://s.w.org/images/home/screen-themes.png?1)

## Configuration

Utilisez le panneau d'administration de votre Wordpress pour configurer l'application.

## Documentation

 * Documentation officielle : https://codex.wordpress.org/
 * Documentation YunoHost : Si une documentation spécifique est nécessaire, n'hésitez pas à contribuer.

## Caractéristiques spécifiques YunoHost

 * Intégration avec les utilisateurs YunoHost et SSO :
   * Mode privé : blog uniquement accessible aux utilisateurs de YunoHost.
   * Mode public : visible par tous, les utilisateurs de YunoHost se connectent automatiquement.
 * Mise à jour automatique du noyau Wordpress, des plugins et des thèmes.
 * Autoriser la mise en place de [multisite](https://codex.wordpress.org/Glossary#Multisite) sur une instance.

#### Support multi-utilisateur

Pris en charge, avec LDAP et SSO.

#### Architectures supportées

* x86-64 - [![](https://ci-apps.yunohost.org/ci/logs/wordpress%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/wordpress/)
* ARMv8-A - [![](https://ci-apps-arm.yunohost.org/ci/logs/wordpress%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/wordpress/)
* Buster x86-64b - [![](https://ci-buster.nohost.me/ci/logs/wordpress%20%28Apps%29.svg)](https://ci-buster.nohost.me/ci/apps/wordpress/)

## Limitations

* Multisite uniquement disponible sur les sous-répertoires.
* Le plugin de mise à jour automatique ne fonctionne pas comme prévu, attention donc à garder votre Wordpress à jour depuis le panneau d'administration Wordpress et pas seulement depuis le panneau d'administration YunoHost. Pour des raisons de sécurité, vous devez effectuer régulièrement toutes les mises à jour dans l'administration Wordpress ainsi que dans l'administration YunoHost.

**Securité**

Veuillez noter que Wordpress est connu pour être fréquemment une source de risques pour la sécurité (https://en.wikipedia.org/wiki/WordPress#Vulnerabilities), et en tant que système de gestion de site Web le plus populaire, il est une cible pour les bots et les attaquants. Certaines vulnérabilités pourraient laisser un attaquant pénétrer votre Wordpress, ou même votre serveur YunoHost (via une élévation de privilèges).

N'oubliez pas de respecter les principes de sécurité de base (mot de passe fort, mises à jour fréquentes, n'ajoutez pas de code inconnu dans votre thème / extensions...). En particulier, *veuillez garder votre Wordpress aussi à jour que possible*.

De plus, vous pouvez consulter ce guide : https://codex.wordpress.org/Hardening_WordPress. Vous pourriez voir certains avantages dans l'utilisation des plugins de sécurité Wordpress.

## Liens

 * Signaler un bug : https://github.com/YunoHost-Apps/wordpress_ynh/issues
 * Site de l'application : https://wordpress.org/
 * Dépôt de l'application principale : https://core.trac.wordpress.org/browser  
 https://build.trac.wordpress.org/browser
 * Site web YunoHost : https://yunohost.org/

---

Informations pour les développeurs
----------------

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
ou
sudo yunohost app upgrade wordpress -u https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
```
