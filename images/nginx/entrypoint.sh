#!/usr/bin/env sh

envsubst '${PHP_FPM_ADDR} ${PHP_FPM_SCRIPT_FILENAME}' \
    < /etc/nginx/default.template.conf \
    > /etc/nginx/conf.d/default.conf

nginx -g "daemon off;"
