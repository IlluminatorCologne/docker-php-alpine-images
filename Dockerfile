# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target

# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG PHP_BUILD_VERSION=8.3

# "php" stage
FROM php:${PHP_BUILD_VERSION}-fpm-alpine AS php-fpm-alpine-base

ARG PHP_BUILD_VERSION
# persistent / runtime deps
RUN apk add --update --no-cache \
        acl \
		ca-certificates \
        curl \
        fcgi \
		file \
		gettext \
		git \
        nodejs \
        npm \
    && rm -rf /var/cache/apk/* \
    && update-ca-certificates

###> php extensions ###
RUN pear config-set http_proxy ${http_proxy:-""}
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions intl apcu opcache zip
###< php extensions###

COPY --from=composer/composer:2-bin /composer /usr/bin/composer

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY php/conf.d/php.ini $PHP_INI_DIR/conf.d/php.ini

COPY php/php-fpm.d/${PHP_BUILD_VERSION}/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

VOLUME /var/run/php

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

# build for production
ARG APP_ENV=prod

VOLUME /srv/app/var

COPY php/docker-healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck

HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD ["docker-healthcheck"]

# +x is not needed for this, as it will just be sourced from entrypoint scripts
COPY php/docker-common.sh /usr/local/bin/docker-common.sh
COPY php/docker-entrypoint-api.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]


## ## ## image php-fpm-alpine-api-pgsql
#
FROM php-fpm-alpine-base as php-fpm-alpine-api-pgsql
RUN install-php-extensions pdo_pgsql
RUN set -eux; \
	apk add --no-cache  \
        yarn \
	;

## ## ## image php-fpm-alpine-gui
#
FROM php-fpm-alpine-base as php-fpm-alpine-gui
RUN install-php-extensions redis
RUN set -eux; \
	apk add --no-cache  \
        yarn \
	;
COPY php/docker-entrypoint-gui.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint
