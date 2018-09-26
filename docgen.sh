#!/bin/bash

set -x
rm -rf ./docs
mkdir ./docs
# cp README.md docs/

JAZZY=$(type -p jazzy)
[[ -n "${JAZZY}" ]] && ${JAZZY} -x -workspace,JoyStickView.xcworkspace,-scheme,JoyStickView
