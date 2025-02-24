#!/bin/bash

pushd "$(dirname ${BASH_SOURCE[0]})" > /dev/null

mkdir -p third-party
git clone https://github.com/MCUdude/MiniCore third-party/minicore
git clone https://github.com/adafruit/Adafruit_BusIO third-party/Adafruit_BusIO
git clone https://github.com/mathertel/RotaryEncoder third-party/RotaryEncoder

popd > /dev/null