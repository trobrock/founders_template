#!/usr/bin/env bash

echo "Tagging Docker images"
docker tag app:$GIT_COMMIT_SHA $APP_REPOSITORY_URI:$IMAGE_TAG
docker tag app:$GIT_COMMIT_SHA $APP_REPOSITORY_URI:latest
docker tag web:$GIT_COMMIT_SHA $WEB_REPOSITORY_URI:$IMAGE_TAG
docker tag web:$GIT_COMMIT_SHA $WEB_REPOSITORY_URI:latest
