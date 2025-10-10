# docker-php-alpine-images

Maintainer
-----
* Carsten Reuter (IlluminatorCologne@gmx.de)

Available images
-----
The base image contains:
* ssl certificates
* entrypoint script
* healthcheck script
* PHP extensions:
  *```intl | apcu-stable | opcache | zip```

Child images:

* ghcr.io/IlluminatorCologne/php-fpm-alpine-api-pgsql:[**8.3** ]
  * ```pgsql```
* ghcr.io/IlluminatorCologne/php-fpm-alpine-api-mysql:[**8.3**]
  * ```mysql```


Usage
-----
To use the image in your Dockerfile declare it as base image
```
FROM ghcr.io/illuminatorcologne/php-fpm-alpine-api-pgsql:8.31 AS my_image
```

PHP Extensions
----
If your application needs additional php or pecl extensions run this command :

``` RUN install-php-extensions [EXTENSION_NAME_1] [EXTENSION_NAME_2]  ```