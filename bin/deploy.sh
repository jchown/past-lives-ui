#!/bin/bash

set -e

docker="docker run --rm -v $(pwd)/:/app/ -w /app"
yarn="$docker node:18-alpine yarn"

$yarn install
$yarn build

aws="$docker -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY amazon/aws-cli"

$aws s3 --region eu-west-2 sync dist/ s3://www.datasmelter.com/history/past-lives/ --delete --acl public-read

invalidation_output=$($docker cloudfront create-invalidation --distribution-id E3LWUSSIKV8P0V --paths /history/\*)
invalidation_id=$(echo $invalidation_output | jq -r '.Invalidation.Id')
$docker cloudfront wait invalidation-completed --id $invalidation_id --distribution-id E3LWUSSIKV8P0V
