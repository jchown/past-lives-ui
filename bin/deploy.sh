#!/bin/bash

set -e

docker="docker run --rm -v $(pwd)/:/app/ -w /app"
yarn="$docker node:18-alpine yarn"

$yarn install
$yarn build

aws="$docker -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY amazon/aws-cli"

$aws s3 --region eu-west-2 sync dist/ s3://www.datasmelter.com/history/past-lives/ --delete --acl public-read
