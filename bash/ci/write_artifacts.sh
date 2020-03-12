#!/usr/bin/env bash

echo Writing image definitions file...
printf '[{"name":"app","imageUri":"%s"}, {"name":"web","imageUri":"%s"}]' $APP_REPOSITORY_URI:$IMAGE_TAG $WEB_REPOSITORY_URI:$IMAGE_TAG > web_imagedefinitions.json
printf '[{"name":"worker","imageUri":"%s"}]' $APP_REPOSITORY_URI:$IMAGE_TAG > worker_imagedefinitions.json
