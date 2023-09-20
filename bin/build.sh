#!/usr/bin/env bash

set -eu

PWD=$(pwd)
TIMESTAMP="${TIMESTAMP:-$(date -u +"%Y%m%d%H%M%S")}"
USERID="${USERID:-$(id -u)}"

cat $BUILD_MATRIX | while read build; do
    board="$(echo $build | sed 's/.*"board":"\([^"]*\)".*/\1/')"
    shield="$(echo $build | sed 's/.*"shield":"\([^"]*\)".*/\1/')"
    dash_shield=$(echo ${shield:+$shield} | sed 's/ /-/g')
    extra_cmake_args=${shield:+-DSHIELD="$shield"}
    display_name=${shield:+$shield - }${board}
    artifact_name=${TIMESTAMP}-${dash_shield:+$dash_shield-}${board}-zmk

    echo -e "\nEnvironment:"
    echo "zephyr_version: ${ZEPHYR_VERSION}"
    echo "board: ${board}"
    echo "shield: ${shield}"
    echo "extra_cmake_args: ${extra_cmake_args}"
    echo "display_name: ${display_name}"
    echo "artifact_name: ${artifact_name}"
    echo -e "\n"

    echo -e "Building ${display_name}\n"
    west build -s zmk/app -b "$board" -d build/${dash_shield} -- -DZMK_CONFIG="${PWD}/config" "${extra_cmake_args}"

    echo -e "${display_name} KConfig\n"
    grep -v -e "^#" -e "^$" build/${dash_shield}/zephyr/.config | sort

    cp build/${dash_shield}/zephyr/zmk.uf2 "firmware/${artifact_name}.uf2"

    chown ${USERID} firmware/*
done
