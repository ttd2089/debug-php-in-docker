# Debug PHP In Docker

## Intention

Create a development environment that supports debugging a PHP application with minimal setup required.

## Requirements

- [x] The environment should run with no host dependencies other than Docker compose.
- [x] The environment should run using a single command with no source modifications.
- [x] Changes to the PHP _source_ should be reflected by the server on the next request without manual intervention.
- [ ] The project should document the debug configuration required for a local IDE to debug the application in Docker.
- [ ] The project should contain a concrete debug configuration for VS Code that works automatically, or with a trivial copy/paste/edit. 
- [ ] Debugging should not be coupled to a web server choice.
- [x] The environment should re-use image definitions that can also be the basis of production images.

## Docker Images

Each [docker image](./images) in the project uses build targets to define a common base, a development image, and a production image. The base targets define everything the development and production images have in common (software versions, configuration, etc.), and the development and production targets define only what makes development and production different from each other (development contains a debugger, production images contain the source but development images need it mounted in at runtime, etc.). This strategy facilitates keeping development and production resources in sync without duplication.

## Compose Environment

The compose environment runs the development and production versions of the PHP application, as well as an NGINX and an Apache reverse proxy pointing to each one. The development version of the application runs so that we can connect a debugger and prove it works. The production version runs so we can prove that the build target strategy works. We run multiple servers to prove that we haven't coupled the ability to debug the application to a particular choice of server.

_NOTE: At the time of writing we do **not** run multiple web servers, but we plan to and we're confident in ourselves._

### Services

### php

The `php` service is the primary focus of this project. It seeks to meet the stated [Requirements](#requirements) by defining a `bas`e target that serves the PHP application using PHP FPM, installing a debugger and serving a mounted-in version of the source from `php-dev`, and serving a copied-in version of the source from `php-prod`. After running `docker compose up`, requests to `localhost:8080` (`php-dev`) will reflect changes made to [`index.php`](./src/index.php) but requests made to `localhost:8000` (`php-prod`) will not.

A more realistic application would have other considerations like dependencies to be restored or transpilers to be run. In that case we might use an additional `builder` target to house the required tooling, derive the `dev` target from the `builder` target, derive a new `build` target from the `builder` target to produce the production source, then derive `prod` from the `base` target and copy in the built artifact from the `build` target.

### NGINX

The `nginx` service is a simply reverse proxy to serve our PHP FPM application. There is currently no different between the `dev` and `prod` targets; instead the differences between the `nginx-dev` and `nginx-prod` services are defined via the deployment environment and the `base` target supports the required configuration options.

`PHP_FPM_ADDR`
: The host and port for the PHP FPM instance that NGINX should proxy requests to.

`PHP_FPM_SCRIPT_FILENAME`
: The absolute path to the PHP file **_on the php service_**. Examples tend to use `$document_root$fastcgi_script_name` but `$document_root` refers to the root of the NGINX virtual server so this seems to creates a coupling between between the NGINX config and remote CGI server's file system.
