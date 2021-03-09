# ledstrain-docker

## Versioning

x-y-z

* x = flarum version
* y = plugin changes (added or removed)
* z = minor changes  
For example, the below shows the flarum version, 1 plugin or update change at that version, and 5 minor changes
```
0.1.0-beta.15-01-05
x = 0.1.0-beta.15, y = 01, z = 05
```

## Making changes

These programs are used
* docker
* docker-compose
* just

`docker/composer.json` and `docker/compose.lock` are used to configure the forum when building the image.  
If these two files are changed, make sure to run `docker-compose build`

### Composer

[just](https://github.com/casey/just) is used as a command runner to make testing easier.  
To enter the container run `just enter`  
While in the container, install, update or remove plugins as needed. Eg `composer update`.  
Exit out of the container (`Ctrl-D`) and run `just update` to copy the `composer.json` and `composer.lock` files out.  
If `composer.json` is changed, a `git diff | grep` command is run to show any changes.  
Review the changes in git before committing.  



## Docker

`webdevops/php-nginx` docker image base is used, and then is configured on top of it.

When the image is built, it is meant to provide the structure but not the data for the forum and should be considered immutable.
This includes items like

* Core files
* All plugins
* Scheduled services

It does not include
* User files like avatars
* Database files

To update, add or remove any plugins, see [Composer](#composer)
