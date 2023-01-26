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
                     dev environment v1.0.0

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

# Run docker and "fix" permissions (don't you even dare to use it on production)
if [ "$1" = "up" ]; then
  docker compose up -d \
    && sudo find "$PRESTASHOP_DIRECTORY" -type d -exec chmod 777 {} + \
    && sudo find "$PRESTASHOP_DIRECTORY" -type f -exec chmod 666 {} +
else
  docker compose "$1"
fi
