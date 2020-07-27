#!/bin/bash

set -x
rm -rf ./docs
mkdir ./docs
cp animation.gif docs/

JAZZY=$(type -p jazzy)
[[ -n "${JAZZY}" ]] && \
    ${JAZZY} --module JoyStickView \
             --build-tool-arguments -workspace,JoyStickView.xcworkspace,-scheme,JoyStickView \
             --root-url https://bradhowes.github.io/Joystick
