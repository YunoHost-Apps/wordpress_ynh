<!--
Nota bene : ce README est automatiquement généré par <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
Il NE doit PAS être modifié à la main.
-->

# WordPress pour YunoHost

[![Niveau d’intégration](https://dash.yunohost.org/integration/wordpress.svg)](https://dash.yunohost.org/appci/app/wordpress) ![Statut du fonctionnement](https://ci-apps.yunohost.org/ci/badges/wordpress.status.svg) ![Statut de maintenance](https://ci-apps.yunohost.org/ci/badges/wordpress.maintain.svg)

[![Installer WordPress avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=wordpress)

*[Lire le README dans d'autres langues.](./ALL_README.md)*

> *Ce package vous permet d’installer WordPress rapidement et simplement sur un serveur YunoHost.*  
> *Si vous n’avez pas YunoHost, consultez [ce guide](https://yunohost.org/install) pour savoir comment l’installer et en profiter.*

## Vue d’ensemble

WordPress est un logiciel libre que vous pouvez utiliser pour créer un site ou un blog.
Avec ce package, vous pouvez même activer l'option [multisite](https://codex.wordpress.org/Glossary#Multisite).


**Version incluse :** 6.5~ynh1

## Captures d’écran

![Capture d’écran de WordPress](./doc/screenshots/screen-themes.png)

## :red_circle: Anti-fonctionnalités

- **Extensions non libres **: Promeut d'autres applications ou plugins non libres.
- **Contenu payant **: Promeut ou dépend, entièrement ou partiellement, d'un service payant.

## Documentations et ressources

- Site officiel de l’app : <https://wordpress.org/>
- Documentation officielle de l’admin : <https://codex.wordpress.org/>
- Dépôt de code officiel de l’app : <https://core.trac.wordpress.org/browser>
- YunoHost Store : <https://apps.yunohost.org/app/wordpress>
- Signaler un bug : <https://github.com/YunoHost-Apps/wordpress_ynh/issues>

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche `testing`](https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing).

Pour essayer la branche `testing`, procédez comme suit :

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
ou
sudo yunohost app upgrade wordpress -u https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
```

**Plus d’infos sur le packaging d’applications :** <https://yunohost.org/packaging_apps>
