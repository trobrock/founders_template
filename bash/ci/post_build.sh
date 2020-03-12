#!/usr/bin/env bash

set -e

CUSTOM_INSTALL_FILE="ci/post_install.sh"

ft ci push_images
ft ci write_artifacts

if [ -f "$CUSTOM_INSTALL_FILE" ] ; then
  echo "Running custom install"
  exec bash "$CUSTOM_INSTALL_FILE"
fi
