#!/usr/bin/env bash

set -e

CUSTOM_POST_BUILD_FILE="ci/post_build.sh"

ft ci push_images
ft ci write_artifacts

if [ -f "$CUSTOM_POST_BUILD_FILE" ] ; then
  echo "Running custom post build script"
  exec bash "$CUSTOM_POST_BUILD_FILE"
fi
