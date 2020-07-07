# Wordpress pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/wordpress.svg)](https://dash.yunohost.org/appci/app/wordpress) ![](https://ci-apps.yunohost.org/ci/badges/wordpress.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/wordpress.maintain.svg)  
[![Installer Wordpress avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=wordpress)

*[Read this readme in english.](./README.md)* 

> *Ce package vous permet d'installer Wordpress rapidement et simplement sur un serveur YunoHost.  
Si vous n'avez pas YunoHost, consultez [le guide](https://yunohost.org/#/install) pour apprendre comment l'installer.*

## Vue d'ensemble
WordPress est un logiciel libre que vous pouvez utiliser pour créer un site ou un blog.
Avec ce package, vous pouvez même activer l'option [multisite](https://codex.wordpress.org/Glossary#Multisite).

**Version incluse :** 5.4

## Captures d'écran

![](https://s.w.org/images/home/screen-themes.png?1)

## Configuration

Utilisez le panneau d'administration de votre WordPress pour le configurer.

## Documentation

 * Documentation officielle : https://codex.wordpress.org/
 * Documentation YunoHost : https://yunohost.org/#/app_wordpress
 
## Caractéristiques spécifiques YunoHost

 * Intégration avec les utilisateurs YunoHost et le SSO :
   * en mode privé : Le blog ou le site est accessible uniquement aux utilisateurs YunoHost
   * en mode public : Le blog ou le site est accessible par n'importe qui et les utilisateurs YunoHost sont automatiquement connectés
 * Mises à jour automatiques du cœur de WordPress, extentions et thèmes.
 * Capable de configurer une instance [multisite](https://codex.wordpress.org/Glossary#Multisite).

#### Support multi-utilisateur

Supporté, avec LDAP et SSO.

#### Architectures supportées

* x86-64b - [![](https://ci-apps.yunohost.org/ci/logs/wordpress%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/wordpress/)
* ARMv8-A - [![](https://ci-apps-arm.yunohost.org/ci/logs/wordpress%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/wordpress/)
* Buster x86-64b - [![](https://ci-buster.nohost.me/ci/logs/wordpress%20%28Apps%29.svg)](https://ci-buster.nohost.me/ci/apps/wordpress/)

## Limitations

* Le multisite n'est disponible que sur des sous-domaines.
* Comme les mises à jour automatiques ne fonctionnent pas correctement, prenez soin de bien mettre à jour WordPress via le panneau d'administration de WordPress et pas seulement via le panneau d'administration de YunoHost. Pour des raisons de sécurité, vérifiez bien que toutes les mises à jour sont bien installées dans le panneau d'administration de WordPress comme dans le panneau d'administration de YunoHost.

**Sécurité**

Soyez conscients que WordPress est connu pour avoir souvent des risques de sécurité (https://en.wikipedia.org/wiki/WordPress#Vulnerabilities), donc comme c'est le gestionnaire de sites le plus populaire il est la cible des robots et pirates.
Des vulnérabilités peuvent offrir une brêche dans votre wordpress ou dans votre serveur Yunohost (via l'escalade des droits).

N'oubliez pas d'appliquer tous les bons principes de sécurité (mots de passe forts, mises à jours fréquentes, ne pas ajouter du code inconnu dans le thème et les extensionts…). En particuler, *gardez votre wordpress à jour le plus possible*.

Par ailleurs, vous pourriez avoir besoin de regarder ce guide :  https://codex.wordpress.org/Hardening_WordPress. Installer des extensions de sécurité peut-être une bonne chose.

## Liens

 * Rapporter un bug : https://github.com/YunoHost-Apps/wordpress_ynh/issues
 * Site de Wordpress : https://wordpress.org/
 * Dépôt de Wordpress : https://core.trac.wordpress.org/browser
 https://build.trac.wordpress.org/browser
 * Site de YunoHost : https://yunohost.org/

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
