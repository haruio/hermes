#!/bin/bash
ENV="local" # default mix env

if [ ! -z "$1" ]; then
	ENV=$1
fi

echo "** [$ENV] start hermes **"
env MIX_ENV=$ENV iex -S mix phoenix.server
