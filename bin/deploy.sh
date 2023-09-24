#!/bin/bash

$yarn="docker run --rm -t -v $(pwd)/:/usr/app/ -w /usr/app node:18-alpine yarn"

$yarn install
$yarn build

aws="docker run --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY amazon/aws-cli"

$aws s3 --region eu-west-2 sync dist/ s3://www.datasmelter.com/history/past-lives/ --delete --acl public-read
