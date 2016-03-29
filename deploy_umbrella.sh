#!/bin/bash

if [ -z $1 ]; then
    VERSION=0.0.1
else
    VERSION=$1
fi



cp "./apps/hermes_umbrella_master/rel/hermes_umbrella_master/releases/$VERSION/hermes_umbrella_master.tar.gz" "../hermes_release_test/releases/$VERSION.tar.gz"

tar zxvf "../hermes_release_test/releases/$VERSION.tar.gz" -C "../hermes_release_test/workspace/"
