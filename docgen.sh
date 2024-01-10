#!/bin/bash

set -x
rm -rf ./docs
mkdir ./docs
cp animation.gif docs/

JAZZY=$(type -p jazzy)
[[ -n "${JAZZY}" ]] && \
    ${JAZZY} --module JoyStickView \
             --min-acl internal \
             --build-tool-arguments \
             -workspace,JoyStickView.xcworkspace,-scheme,JoyStickView,-destination,'name=iPhone 15' \
             --root-url https://bradhowes.github.io/Joystick
