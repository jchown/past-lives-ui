#!/bin/bash

set -e

docker="docker run --rm -i -v $(pwd)/:/app/ -w /app"
yarn="$docker node:18-alpine yarn"
aws="$docker -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY amazon/aws-cli"
jq="$docker ghcr.io/docwhat/jq-docker"

$yarn install
$yarn build

$aws s3 --region eu-west-2 sync dist/ s3://www.datasmelter.com/history/past-lives/ --delete --acl public-read

invalidation_output=$($aws cloudfront create-invalidation --distribution-id E3LWUSSIKV8P0V --paths /history/\*)
invalidation_id=$(echo $invalidation_output | $jq '.Invalidation.Id')

$aws cloudfront wait invalidation-completed --id $invalidation_id --distribution-id E3LWUSSIKV8P0V
