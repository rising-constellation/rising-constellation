#!/bin/bash

if [[ $BACK_ONLY == "true" ]]; then
  echo "BACK_ONLY=true, skipping frontend"
  exit 0
fi

export VUE_APP_APPSIGNAL_FRONT=dd16d86f-067b-4667-97ab-feb1715ae883
export VUE_APP_APPSIGNAL_REVISION=$APP_REVISION
export VUE_APP_BASE_URL=https://rising-constellation.com
export NODE_ENV=production

echo "REVISION: $VUE_APP_APPSIGNAL_REVISION"

mkdir -p ~/www-root/asylamba/

function phoenix() {
  cd /home/rc/build
  NODE_ENV= npm ci --prefix ./assets
  npm run deploy --prefix ./assets
  mix phx.digest
  mv priv/static ~/www-root/asylamba/static
}

function vue() {
  cd front
  NODE_ENV= npm ci
  npm run build

  cd /home/rc/build
  mv ./front/dist ~/www-root/asylamba/front
}

phoenix
vue game

tar -czvf /home/rc/build/vue.tar.gz ~/www-root/asylamba
