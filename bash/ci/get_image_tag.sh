#!/usr/bin/env bash

echo "$(ft ci get_git_commit_sha | cut -c 1-7)-$(echo $CODEBUILD_BUILD_ID | sed 's/:/-/g')"
