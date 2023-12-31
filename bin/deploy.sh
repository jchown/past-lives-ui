#!/bin/bash

set -e

docker="docker run --rm -i -v $(pwd)/:/app/ -w /app"
yarn="$docker node:18-alpine yarn"
aws="$docker -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY amazon/aws-cli"
jq="$docker stedolan/jq"

echo "Building site"

$yarn install
$yarn build

echo "Uploading site"

$aws s3 --region eu-west-2 sync dist/ s3://www.datasmelter.com/history/past-lives/ --delete --acl public-read
$aws s3 --region eu-west-2 cp public/ s3://www.datasmelter.com/history/past-lives/ --recursive --acl public-read

echo "Invalidating CDN"

$aws cloudfront create-invalidation --region eu-west-2 --distribution-id E3LWUSSIKV8P0V --paths /history/\* --region eu-west-2 >invalidation.json
invalidation_id=$(cat invalidation.json | $jq -r '.Invalidation.Id')

echo "Waiting for invalidation $invalidation_id"

$aws cloudfront wait invalidation-completed --id $invalidation_id --distribution-id E3LWUSSIKV8P0V --region eu-west-2
