#!/usr/bin/env bash
#################
# This is considered to be the main script for setting up the environment
#  for flarum and must finish before the forum comes up.
# If config.php is not available, it uses the included template to write
#  one from environment variables.
# If one does exist, it will run migrations and clear the cache
# It also creates and changes permissions for flarum to use.
# This script also caches assets for the forum to use.
#
#################
set -e
cd "$APPLICATION_PATH"

printenv | grep -E 'MYSQL_USER|MYSQL_PASSWORD|MYSQL_DATABASE|HOSTNAME|MASTER_TOKEN|BUILD_COMMIT' > /etc/environment

install_flarum() {
  cat > install.yml <<EOF
debug: true
baseUrl: https://${HOSTNAME}
databaseConfiguration:
  driver: mysql
  host: db
  port: 3306
  database: ${MYSQL_DATABASE}
  username: ${MYSQL_USER}
  password: ${MYSQL_PASSWORD}
  prefix:
adminUser:
  username: admin
  password: password
  email: admin@example.com
settings:
EOF
  php flarum install --file install.yml
  cp config.php /conf/config.php
  chown "${PUID_ID}" /conf/config.php
}


mkdir -p \
  /app/public/assets/avatars                 \
  /app/public/assets/extensions              \
  /app/public/assets/files                   \
  /app/public/assets/images                  \
  /app/storage                               \
  /app/vendor/kyrne/websocket/poxa-Linux/tmp

if [ -f /conf/config.php ]; then
  ln -fs /conf/config.php ./config.php
  php flarum migrate
  php flarum assets:publish

  # Requires Cache Assets
  # https://discuss.flarum.org/d/23321-cache-assets-by-bokt
  php flarum cache:clear
  php flarum cache:assets --js --css --locales || true

elif [ "$INSTALL" == "true" ]; then
  install_flarum
fi

# Directory to plugin changes
# /app/vendor/flarum/core/src/Database       # For ReCache plugin
# /app/vendor/kyrne/websocket/poxa-Linux/tmp # For Websocket plugin

chown "${PUID_ID}" -R                        \
  /app/public/assets                         \
  /app/storage                               \
  /app/vendor/flarum/core/src/Database       \
  /app/vendor/kyrne/websocket/poxa-Linux/tmp
