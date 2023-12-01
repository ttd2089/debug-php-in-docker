FROM nginx:1.25.3-alpine3.18 AS base

COPY ./images/nginx/default.template.conf /etc/nginx/
COPY ./images/nginx/entrypoint.sh /

ENTRYPOINT /entrypoint.sh
CMD []

FROM base AS dev

FROM base AS prod
