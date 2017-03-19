# Wordpress multisite for YunoHost
==================

Site du project Yunohost : [Yunohost.org](https://yunohost.org/#/)

## English version
Wordpress lets you create your blog or web site very easily. <br/>
With this package, you can even activate the [multisite](http://codex.wordpress.org/Glossary#Multisite)

https://wordpress.org/

If the multisite option is activated, the script also installs *php5-cli*.

**How to upgrade the package:**  
1) sudo yunohost app upgrade --verbose wordpress -u https://github.com/YunoHost-Apps/wordpress_ynh <br/>
2) To be noted that once installed, the updates of the php code of the Wordpress blog are managed from the Wordpress web admin interface. <br/>
3) There may also be some upgrades of the wordpress_ynh package, these are to cover its integration whithin the Yunohost system.

**Multi-user support:** Yes, with LDAP ability.

## Version Française
Logiciel de création de blog ou de site Web avec option [multisite](http://codex.wordpress.org/Glossary#Multisite)

https://wordpress.org/

Si l'option multisite est activée, le script installe le paquet *php5-cli*.

**Mise à jour du package:**  
1) sudo yunohost app upgrade --verbose wordpress -u https://github.com/YunoHost-Apps/wordpress_ynh <br/>
2) A noter qu'une fois installé, les mises à jour du code php du blog Wordpress se font depuis l'interface wed d'admin de Wordpress  <br/>
3) Il peut également y avoir des mises à jour du paquet wordpress_ynh, celles-ci sont liées à l'intégration du paquet dans le systeme Yunohost.

**Multi-utilisateur:** Oui, avec support ldap.
