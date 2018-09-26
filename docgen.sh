#!/bin/bash

set -x
JAZZY=$(type -p jazzy)
[[ -n "${JAZZY}" ]] && ${JAZZY} -x -workspace,JoyStickView.xcworkspace,-scheme,JoyStickView
