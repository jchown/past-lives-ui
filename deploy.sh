#!/bin/sh

set -e
docker run --rm -v ${PWD}:/app -w /app -e GENERATE_SOURCEMAP=false -e NODE_OPTIONS="--max-old-space-size=8192" node:18 yarn build
docker run --rm -v ${PWD}/dist:/dist -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY amazon/aws-cli s3 sync /dist s3://www.datasmelter.com/history/past-lives --acl public-read --delete
invalidation_output=$(docker run --rm -v ${PWD}/dist:/dist -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY amazon/aws-cli cloudfront create-invalidation --distribution-id E3LWUSSIKV8P0V --paths /history/\*)
invalidation_id=$(echo $invalidation_output | jq -r '.Invalidation.Id')
echo "Waiting for invalidation $invalidation_id to complete"
docker run --rm -v ${PWD}/dist:/dist -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY amazon/aws-cli cloudfront wait invalidation-completed --id $invalidation_id --distribution-id E3LWUSSIKV8P0V
