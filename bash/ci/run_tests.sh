#!/usr/bin/env bash

set -e

extra_environment=""
for e in $@
do
  extra_environment="$extra_environment -e $e"
done

echo Running tests...
sed -i "s;%IMAGE;app:$GIT_COMMIT_SHA;" docker-compose.ci.yml
exec docker-compose -f docker-compose.ci.yml \
  run --entrypoint "/bin/sh -c" \
  -e GIT_COMMIT_SHA \
  -e GIT_COMMITTED_AT \
  $extra_environment \
  app "exec sh ./ci/run_tests.sh"
