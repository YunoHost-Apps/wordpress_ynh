<!--
注意：此 README 由 <https://github.com/YunoHost/apps/tree/master/tools/readme_generator> 自动生成
请勿手动编辑。
-->

# YunoHost 上的 WordPress

[![集成程度](https://apps.yunohost.org/badge/integration/wordpress)](https://ci-apps.yunohost.org/ci/apps/wordpress/)
![工作状态](https://apps.yunohost.org/badge/state/wordpress)
![维护状态](https://apps.yunohost.org/badge/maintained/wordpress)

[![使用 YunoHost 安装 WordPress](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=wordpress)

*[阅读此 README 的其它语言版本。](./ALL_README.md)*

> *通过此软件包，您可以在 YunoHost 服务器上快速、简单地安装 WordPress。*  
> *如果您还没有 YunoHost，请参阅[指南](https://yunohost.org/install)了解如何安装它。*

## 概况

WordPress is open source software you can use to create a beautiful website, blog, or app.  
With this package, you can even activate the [multisite](https://wordpress.org/support/article/glossary/#multisite) option.


**分发版本：** 6.7.0~ynh1

## 截图

![WordPress 的截图](./doc/screenshots/screen-themes.png)

## :red_circle: 负面特征

- **Non-free Addons**: Promotes other non-free applications or plugins.
- **Paid content**: Promotes or depends, entirely or partially, on a paid service.

## 文档与资源

- 官方应用网站： <https://wordpress.org/>
- 官方管理文档： <https://codex.wordpress.org/>
- 上游应用代码库： <https://core.trac.wordpress.org/browser>
- YunoHost 商店： <https://apps.yunohost.org/app/wordpress>
- 报告 bug： <https://github.com/YunoHost-Apps/wordpress_ynh/issues>

## 开发者信息

请向 [`testing` 分支](https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing) 发送拉取请求。

如要尝试 `testing` 分支，请这样操作：

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
或
sudo yunohost app upgrade wordpress -u https://github.com/YunoHost-Apps/wordpress_ynh/tree/testing --debug
```

**有关应用打包的更多信息：** <https://yunohost.org/packaging_apps>
