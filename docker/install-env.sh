#!/usr/bin/env bash

PATH_PREFIX=terrace-backend

ENVS=$(aws ssm get-parameters-by-path \
    --path "/$PATH_PREFIX/" \
    --with-decryption \
    --query "Parameters[*].[Name,Value]" \
    --output text | sed "s/^\/$PATH_PREFIX\///g" | sed "s/\t/=/g")


# prepare .env
echo "$ENVS" > .env
cat .env.example | sed -e '1,10d' >> .env

# prepare kong.yml
ANON_KEY=$(echo "$ENVS" | grep 'ANON_KEY' | sed 's/ANON_KEY=//g')
SERVICE_ROLE_KEY=$(echo "$ENVS" | grep 'SERVICE_ROLE_KEY' | sed 's/SERVICE_ROLE_KEY=//g')

cp ./volumes/api/kong.yml.example ./volumes/api/kong.yml

yq -i ".consumers[0].keyauth_credentials[0].key = \"$ANON_KEY\"" ./volumes/api/kong.yml
yq -i ".consumers[1].keyauth_credentials[0].key = \"$SERVICE_ROLE_KEY\"" ./volumes/api/kong.yml
