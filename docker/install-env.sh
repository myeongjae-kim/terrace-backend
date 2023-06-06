#!/usr/bin/env bash

PATH_PREFIX=terrace-backend

ENVS=$(aws ssm get-parameters-by-path \
    --path "/$PATH_PREFIX/" \
    --with-decryption \
    --query "Parameters[*].[Name,Value]" \
    --output text)

echo "$ENVS" | sed "s/^\/$PATH_PREFIX\///g" | sed "s/\t/=/g" > .env

cat .env.example | sed -e '1,10d' >> .env
