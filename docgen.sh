#!/bin/bash

set -x
rm -rf ./docs
mkdir ./docs
cp animation.gif docs/

JAZZY=$(type -p jazzy)
[[ -n "${JAZZY}" ]] && ${JAZZY} --module JoyStickView -x -workspace,JoyStickView.xcworkspace,-scheme,JoyStickView
