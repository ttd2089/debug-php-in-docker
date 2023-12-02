# Debug PHP In Docker

This project is a proof of concept for creating a high-quality, out-of-the-box, development environment for a PHP application.

## Goals

- [x] No local dependencies other than Docker
- [x] Run using a single command with no source modifications
- [x] Changes to the PHP _source_ are reflected immediately and automatically in the PHP service
- [x] README explains the debugging configuration
- [x] Debugging works out-of-the-box with VS Code when a PHP debugging extension is installed in the editor
- [x] The Docker images use common bases for development and production images
- [ ] The development target of the PHP service runs `composer install` when it's re/started
- [ ] The production target of the PHP service includes dependencies restored by `composer install`
- [ ] The application serves API endpoints, server-side rendered HTML pages, and static assets.

## Getting Started

Run the following command from the root of the project to start the development environment.

```sh
docker compose up -d
```

## Application

```sh
# TODO: Make an application that has an API, server-side rendered HTML pages, and some public static assets to POC the HTTP server configurations for routing requests. Likely the best thing to do is put the static assets on the HTTP server and only proxy requests for PHP?
```

## Composer Updates

```sh
# TODO: Make the development target of the PHP service run composer install on start so restarting the service will reflect dependency changes with no need to rebuild images or recreate containers.
```

## Debugging

By default the dev PHP service in the compose environment attempts to connect to a debugger listening on the host at port 9003 for every request. The debug configuration is defined in [images/fpm/xdebug.ini](./images/fpm/xdebug.ini). Changes to the file will be reflected in the dev container immediately, but PHP FPM doesn't watch the config files so the service needs to be restarted for the changes to take effect. The service can be restarted by running the following command from the root of the project.

```sh
docker compose restart php-dev
```

The follwing snippet is a VS Code `launch.json` file that will enable listening for debug connections from the app the compose environment.

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}/src"
            }
        }
    ]
}
```

## Docker Image Definitions

Each [docker image](./images) in the project uses build targets to define a common base, a development target, and a production target. The base targets define everything the development and production targets have in common, and the development and production targets define what makes them different. For example; the base target for the PHP application specifies the PHP version and the extensions used by the application, the development target adds a debugger, and the production target copies in the source code (the development target needs the source to be mounted in at runtime). This strategy facilitates keeping development and production resources in sync without duplication.

## Compose Environment

The compose environment runs the development and production versions of the PHP application, as well as an NGINX ointing to each one. The development version of the application runs so that we can connect a debugger and prove it works. The production version runs so we can prove that the build target strategy works. We run multiple servers to prove that we haven't coupled the ability to debug the application to a particular choice of server.

```sh
# TODO: Add Apache reverse proxies
```

### Services

### php

The `php` service serves our PHP application. The development version of the service -- with live reloading and debugging support -- is exposed by [NGINX](#nginx) on port `:8080`. A production version of the application is also available for A/B testing and is exposed by [NGINX](#nginx) on port `:8000`.

### NGINX

The `nginx` service is a reverse proxy to serve our PHP application. There is currently no different between the `dev` and `prod` targets; instead the differences between the `nginx-dev` and `nginx-prod` services are defined via the deployment environment and the `base` target supports the required configuration options.

`PHP_FPM_ADDR`
: The host and port for the PHP FPM instance that NGINX should proxy requests to.

`PHP_FPM_SCRIPT_FILENAME`
: The absolute path to the PHP file **_on the php service_**. Examples tend to use `$document_root$fastcgi_script_name` but `$document_root` refers to the root of the NGINX virtual server so this seems to creates a coupling between between the NGINX config and remote CGI server's file system.
