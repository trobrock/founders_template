#!/usr/bin/env bash

TARGET="$1"

if [[ "$TARGET" == "app" ]]; then
  HAS_DOCKER_IMAGE="$(docker image ls --filter "reference=$APP_REPOSITORY_URI:latest" --format "{{.ID}}" | wc -l)"
  if [ "$HAS_DOCKER_IMAGE" -eq "1" ]; then
    CACHE_IMAGE="--cache-from $APP_REPOSITORY_URI:latest"
  fi
else
  CACHE_IMAGE="--cache-from app:$GIT_COMMIT_SHA"
fi

echo "Building the $TARGET Docker image... using cache: $CACHE_IMAGE"
exec docker build \
  $CACHE_IMAGE \
  --build-arg GIT_COMMIT_SHA=$GIT_COMMIT_SHA \
  --build-arg RAILS_ENV=$RAILS_ENV \
  --build-arg DATABASE_URL=$DATABASE_URL \
  --build-arg REDIS_URL=$REDIS_URL \
  --build-arg SECRET_KEY_BASE=$RAILS_SECRET_KEY \
  --build-arg RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
  --build-arg AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
  --build-arg AWS_CONTAINER_CREDENTIALS_RELATIVE_URI=$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI \
  -t $TARGET:$GIT_COMMIT_SHA \
  --target $TARGET .
