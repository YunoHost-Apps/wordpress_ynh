## Configuration

Utilisez le panneau d'administration de votre WordPress pour le configurer.

## Caractéristiques spécifiques YunoHost

 * Intégration avec les utilisateurs YunoHost et le SSO :
   * en mode privé : Le blog ou le site est accessible uniquement aux utilisateurs YunoHost
   * en mode public : Le blog ou le site est accessible par n'importe qui et les utilisateurs YunoHost sont automatiquement connectés
 * Mises à jour automatiques du cœur de WordPress, extentions et thèmes.
 * Capable de configurer une instance [multisite](https://codex.wordpress.org/Glossary#Multisite).

#### Support multi-utilisateur

Supporté, avec LDAP et SSO.

## Limitations

* Le multisite n'est disponible que sur des sous-domaines.
* Comme les mises à jour automatiques ne fonctionnent pas correctement, prenez soin de bien mettre à jour WordPress via le panneau d'administration de WordPress et pas seulement via le panneau d'administration de YunoHost. Pour des raisons de sécurité, vérifiez bien que toutes les mises à jour sont bien installées dans le panneau d'administration de WordPress comme dans le panneau d'administration de YunoHost.

**Sécurité**

Soyez conscients que WordPress est connu pour avoir souvent des risques de sécurité (https://en.wikipedia.org/wiki/WordPress#Vulnerabilities), donc comme c'est le gestionnaire de sites le plus populaire il est la cible des robots et pirates.
Des vulnérabilités peuvent offrir une brêche dans votre WordPress ou dans votre serveur YunoHost (via l'escalade des droits).

N'oubliez pas d'appliquer les principes de sécurité de base (mots de passe forts, mises à jours fréquentes, ne pas ajouter du code inconnu dans le thème et les extensionts…). En particuler, *gardez votre Wordpress à jour le plus possible*.

Par ailleurs, vous pourriez avoir besoin de regarder [ce guide](https://wordpress.org/support/article/hardening-wordpress/). Installer des extensions de sécurité peut-être une bonne chose.
