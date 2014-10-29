#!/bin/bash

set -e

DART_DIST=dartsdk-linux-x64-release.zip
DARTIUM_DIST=dartium-linux-x64-release.zip

echo Fetching dart sdk and Dartium
curl http://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/$DART_DIST > $DART_DIST
curl http://storage.googleapis.com/dart-archive/channels/stable/raw/latest/dartium/$DARTIUM_DIST > $DARTIUM_DIST

# Unzipping the files

unzip $DART_DIST > /dev/null
unzip $DARTIUM_DIST > /dev/null
rm $DART_DIST
rm $DARTIUM_DIST
mv dartium-* dartium;

# Setting up the environment variables

export DART_SDK="$PWD/dart-sdk"
export PATH="$DART_SDK/bin:$PATH"
export DARTIUM_BIN="$PWD/dartium/chrome"

# Installing all the dependencies

pub install

# Launching xvfb

sh -e /etc/init.d/xvfb start

# Starting Karma

./node_modules/karma/bin/karma start --single-run --browsers Dartium