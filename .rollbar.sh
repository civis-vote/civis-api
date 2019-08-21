#!/bin/bash
function start_deployment() {
  deploy_id="$(curl --request POST --url https://api.rollbar.com/api/1/deploy/ --data '{"access_token": "'"$2"'", "environment": "'"${DEPLOYENV}"'", "revision": "'"${TRAVIS_COMMIT}"'", "comment": "Deployment started in '"${DEPLOYENV}"' for '"${APPLICATION_NAME}"'", "status": "'"$1"'", "local_username": "'"${AUTHOR_NAME}"'"}' | python -c 'import json, sys; obj = json.load(sys.stdin); print obj["data"]["deploy_id"]')"
  echo "$deploy_id" >> ~/deploy_id_from_rollbar
}

function set_deployment_success() {
  curl --request PATCH --url "https://api.rollbar.com/api/1/deploy/${DEPLOY_ID}?access_token=$2" --data '{"status": "'"$1"'"}'
}

if [ "$1" == "started" ]
then
  echo "$1"
  start_deployment started
else
  set_deployment_success succeeded
fi
