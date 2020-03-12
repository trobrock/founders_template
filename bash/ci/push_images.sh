#!/usr/bin/env bash

echo "Pushing the Docker images"
docker push $APP_REPOSITORY_URI:$IMAGE_TAG
docker push $APP_REPOSITORY_URI:latest
docker push $WEB_REPOSITORY_URI:$IMAGE_TAG
docker push $WEB_REPOSITORY_URI:latest
