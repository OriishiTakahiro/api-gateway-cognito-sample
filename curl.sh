#!/bin/sh

set -xo

CLIENT_ID=4g8ef9rp919ahn6ff970m2gj5m
USERNAME=demo-user
PASSWORD=G8J*6zNbCvsZ
API_ENDPOINT=https://u6aduvlf9e.execute-api.ap-northeast-1.amazonaws.com/demo-stage

TOKEN=`aws cognito-idp initiate-auth --client-id ${CLIENT_ID} --auth-flow USER_PASSWORD_AUTH  --auth-parameters "USERNAME=${USERNAME},PASSWORD=${PASSWORD}" --query "AuthenticationResult.IdToken" --output text`
curl -H "Authorization: ${TOKEN}" ${API_ENDPOINT}/demo
