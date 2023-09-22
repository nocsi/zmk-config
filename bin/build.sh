#!/usr/bin/env bash

set -eu

CONFIG_DIR="${CONFIG_DIR:-$(pwd)/config}"
TIMESTAMP="${TIMESTAMP:-$(date -u +"%Y%m%d%H%M%S")}"
BUILD_MATRIX="${BUILD_MATRIX:-build.yaml}"
USERID="${USERID:-$(id -u)}"

while IFS=$',' read -r board shield; do
    extra_cmake_args=${shield:+-DSHIELD="$shield"}
    artifact_name=${shield:+${shield// /-}-}${board}-zmk
    build_dir="build/${artifact_name}"

    echo ""
    echo "-----------------"
    echo "BUILDING FIRMWARE"
    echo "-----------------"
    echo "Zephyr: ${ZEPHYR_VERSION}"
    echo "Board: ${board}"
    echo "Shield: ${shield}"
    echo ""

    if [[ ! -d "$build_dir" ]]; then
        west build -s zmk/app -b "$board" -d ${build_dir} -- \
            -DZMK_CONFIG="$CONFIG_DIR" "${extra_cmake_args}"
    else
        west build -d ${build_dir} -- -DZMK_CONFIG="$CONFIG_DIR"
    fi

    # # echo -e "${display_name} KConfig\n"
    # # grep -v -e "^#" -e "^$" ${build_dir}/zephyr/.config | sort

    cp ${build_dir}/zephyr/zmk.uf2 "firmware/${TIMESTAMP}-${artifact_name}.uf2"

    chown ${USERID} -R ${build_dir}
done < <(yq '
    [{"board": .board[], "shield": .shield[] // ""}] + .include
    | filter(.board)
    | unique_by(.board + .shield).[]
    | [.board, .shield // ""]
    | @csv
' ${BUILD_MATRIX_PATH})

chown ${USERID} firmware/*
