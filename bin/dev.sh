#!/bin/bash

cat << "EOF"
██████╗ ██████╗ ███████╗███████╗████████╗ █████╗
██╔══██╗██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗
██████╔╝██████╔╝█████╗  ███████╗   ██║   ███████║
██╔═══╝ ██╔══██╗██╔══╝  ╚════██║   ██║   ██╔══██║
██║     ██║  ██║███████╗███████║   ██║   ██║  ██║
╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝

           ███████╗██╗  ██╗██████╗ ███████╗██████╗ ████████╗
           ██╔════╝╚██╗██╔╝██╔══██╗██╔════╝██╔══██╗╚══██╔══╝
           █████╗   ╚███╔╝ ██████╔╝█████╗  ██████╔╝   ██║
           ██╔══╝   ██╔██╗ ██╔═══╝ ██╔══╝  ██╔══██╗   ██║
        ██╗███████╗██╔╝ ██╗██║     ███████╗██║  ██║   ██║
        ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝
                     dev environment v1.1.0

EOF

# Everyone dies sometime :)
if [ "$1" != "up" ] && [ "$1" != "down" ] && [ "$1" != "start" ] && [ "$1" != "stop" ] && [ "$1" != "pause" ] && [ "$1" != "build" ]
then
  echo "What should we do? Enter up/down/start/stop/pause as first argument."
  exit 1
fi
if [ "$2" = "" ]
then
  echo "Enter PrestaShop version as second argument (i.e. 1.7.8.8)."
  exit 1
fi

# Creating bulletproof path to the ./bin directory
BIN_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
BIN_PATH="$(cd -- "$BIN_PATH" && pwd)"

# Creating PrestaShop path using second argument
PRESTASHOP_DIRECTORY="$BIN_PATH/../builds/prestashop_$2"

# If we have "up" as first argument and PrestaShop directory does not exist
if [ "$1" = "up" ] && [ ! -d "$PRESTASHOP_DIRECTORY" ]; then

  # Creating directory
  mkdir -p "$PRESTASHOP_DIRECTORY/.docker"

  # Copying .env, docker-compose.yml and Dockerfile
  cp "$BIN_PATH/../src/.env" "$PRESTASHOP_DIRECTORY"
  cp "$BIN_PATH/../src/docker-compose.yml" "$PRESTASHOP_DIRECTORY"
  cp -r "$BIN_PATH/../src/.docker" "$PRESTASHOP_DIRECTORY"

  # Setting specified PrestaShop version inside .env file using sed
  sed -i "s/{PRESTASHOP_VERSION}/$2/g" "$PRESTASHOP_DIRECTORY/.env"
fi

# Change directory to specified PrestaShop
cd "$PRESTASHOP_DIRECTORY" || exit 1

# Checking if docker compose sub-command exists
DOCKER_COMPOSE_OUTPUT=$(docker compose 2>&1)

# Run docker and "fix" permissions (don't you even dare to use it on production)
if [ "$1" = "up" ]; then

  # Using docker compose or docker-compose
  if echo "$DOCKER_COMPOSE_OUTPUT" | grep -q "not a docker command"; then
    docker-compose up -d
  else
    docker compose up -d
  fi

  # Creating path to the lockfile which indicates that permissions were already fixed
  PERMISSIONS_LOCKFILE="$PRESTASHOP_DIRECTORY/.docker/locks/permissions_fixed.lock"

  # Fixing permissions only once by creating lockfile
  if ! test -f "$PERMISSIONS_LOCKFILE"; then
    sudo find "$PRESTASHOP_DIRECTORY" -type d -exec chmod 777 {} + \
      && sudo find "$PRESTASHOP_DIRECTORY" -type f -exec chmod 666 {} + \
      && touch "$PERMISSIONS_LOCKFILE"
  fi

  # Creating path to the lockfile which indicates that MailHog was already configured
  MAILHOG_LOCKFILE="$PRESTASHOP_DIRECTORY/.docker/locks/mailhog_configured.lock"

  # PrestaShop is currently installing in background (by default).
  # So we are trying to execute script via wget which reconfigures PrestaShop to use SMTP (max 20 tries).
  #
  # It may also be that the current configuration of the .env file does not allow auto install.
  # Then this operation will fail after 20 attempts and it will be necessary to manually configure
  # PrestaShop to use SMTP in the backoffice.
  if ! test -f "$MAILHOG_LOCKFILE"; then
    wget -q --spider --tries=20 http://localhost:8080/.docker/scripts/mailhog.php \
      && touch "$MAILHOG_LOCKFILE" &
  fi
else

  # Using docker compose or docker-compose
  if echo DOCKER_COMPOSE_OUTPUT | grep -q "not a docker command"; then
      docker-compose "$1"
  else
      docker compose "$1"
  fi
fi
