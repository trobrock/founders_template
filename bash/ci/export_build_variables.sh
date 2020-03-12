#!/usr/bin/env bash

cat <<-EOF
export \
GIT_COMMIT_SHA=$CODEBUILD_RESOLVED_SOURCE_VERSION \
GIT_COMMITTED_AT=$(echo $CODEBUILD_START_TIME | sed 's/.\{3\}$//') \
IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)-$(echo $CODEBUILD_BUILD_ID | sed 's/:/-/g')
EOF
