optional_dep_install() {
  if [ "$APP_ENV" != 'prod' ]; then
    rm -f .env.local.php

    if ! curl -I --connect-timeout 2.5 "https://repo.packagist.org/packages.json" 2>&1 | grep -w "200\|301" > /dev/null ; then
      echo "Packagist.org is not reachable..."
    fi

    composer config github-oauth.github.com ${GITHUB_TOKEN}
    composer install --prefer-dist --no-progress --no-interaction
  fi
}