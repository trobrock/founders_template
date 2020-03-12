#!/usr/bin/env bash

set -e

CUSTOM_INSTALL_FILE="ci/install.sh"

ft ci print_versions

if [ -f "$CUSTOM_INSTALL_FILE" ] ; then
  echo "Running custom install"
  exec bash "$CUSTOM_INSTALL_FILE"
fi
