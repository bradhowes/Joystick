#!/bin/bash

set -x
rm -rf ./docs
mkdir ./docs
cp animation.gif docs/

# NOTE: the main branch for this repo is `main` and not `master`. However, Github Pages expects to
# look at a `master` branch for a `/docs` directory. So, we have two branches (main and master) and
# we must always keep them the same when the docs change.

JAZZY=$(type -p jazzy)
[[ -n "${JAZZY}" ]] && \
    ${JAZZY} --module JoyStickView \
             --build-tool-arguments \
             -workspace,JoyStickView.xcworkspace,-scheme,JoyStickView,-destination,'name=iPhone 11' \
             --root-url https://bradhowes.github.io/Joystick
