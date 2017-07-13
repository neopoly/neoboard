#!/bin/bash

set -ex

mkdir -p priv/static/images
cp -R node_modules/emojify.js/dist/images/basic priv/static/images/emoji
