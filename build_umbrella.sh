#!/bin/bash
UMBRELLA_PATH="$PWD/apps/hermes_umbrella_master"

ENV="dev"

if [ ! -z "$1" ]; then
    ENV=$1
fi

echo "** [$ENV] start build umbrella **"

cd $UMBRELLA_PATH
echo "$PWD"
env MIX_ENV=$ENV mix deps.get

rm $UMBRELLA_PATH/config/hermes_umbrella_master.conf  $UMBRELLA_PATH/config/hermes_umbrella_master.schema.exs

env MIX_ENV=$ENV mix conform.new &&
env MIX_ENV=$ENV mix conform.configure
# env MIX_ENV=$ENV mix conform.release

env MIX_ENV=$ENV mix compile &&
env MIX_ENV=$ENV mix release.clean --no-confirm &&
env MIX_ENV=$ENV mix release --no-confirm
