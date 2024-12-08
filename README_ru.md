<!--
Важно: этот README был автоматически сгенерирован <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
Он НЕ ДОЛЖЕН редактироваться вручную.
-->

# WordPress для YunoHost

[![Уровень интеграции](https://apps.yunohost.org/badge/integration/wordpress)](https://ci-apps.yunohost.org/ci/apps/wordpress/)
![Состояние работы](https://apps.yunohost.org/badge/state/wordpress)
![Состояние сопровождения](https://apps.yunohost.org/badge/maintained/wordpress)

[![Установите WordPress с YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=wordpress)

*[Прочтите этот README на других языках.](./ALL_README.md)*

> *Этот пакет позволяет Вам установить WordPress быстро и просто на YunoHost-сервер.*  
> *Если у Вас нет YunoHost, пожалуйста, посмотрите [инструкцию](https://yunohost.org/install), чтобы узнать, как установить его.*

## Обзор

WordPress is open source software you can use to create a beautiful website, blog, or app.  
With this package, you can even activate the [multisite](https://wordpress.org/support/article/glossary/#multisite) option.


**Поставляемая версия:** 6.7.0~ynh1

## Снимки экрана

![Снимок экрана WordPress](./doc/screenshots/screen-themes.png)

## :red_circle: Анти-функции

- **Non-free Addons**: Promotes other non-free applications or plugins.
- **Paid content**: Promotes or depends, entirely or partially, on a paid service.

## Документация и ресурсы

- Официальный веб-сайт приложения: <https://wordpress.org/>
- Официальная документация администратора: <https://codex.wordpress.org/>
- Репозиторий кода главной ветки приложения: <https://core.trac.wordpress.org/browser>
- Магазин YunoHost: <https://apps.yunohost.org/app/wordpress>
- Сообщите об ошибке: <https://github.com/YunoHost-Apps/wordpress_ynh/issues>

## Информация для разработчиков

Пришлите Ваш запрос на слияние в [ветку `testing`](https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing).

Чтобы попробовать ветку `testing`, пожалуйста, сделайте что-то вроде этого:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
или
sudo yunohost app upgrade wordpress -u https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
```

**Больше информации о пакетировании приложений:** <https://yunohost.org/packaging_apps>
