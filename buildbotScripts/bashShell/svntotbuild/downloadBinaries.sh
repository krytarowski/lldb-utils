#!/usr/bin/env bash
set -e
source setEnv.sh
rev=$1

cd "$buildDir"
gsutil cp $gsbinaries/rev-$rev.zip .
unzip -o rev-$rev.zip
rm -f rev-$rev.zip
