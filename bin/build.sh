#!/usr/bin/env bash

set -eu

CONFIG_DIR="${CONFIG_DIR:-$(pwd)/config}"
TIMESTAMP="${TIMESTAMP:-$(date -u +"%Y%m%d%H%M%S")}"
BUILD_MATRIX_PATH="${BUILD_MATRIX_PATH:-build.yaml}"
USERID="${USERID:-$(id -u)}"

while IFS=$',' read -r board shield; do
    extra_cmake_args=${shield:+-DSHIELD="$shield"}
    display_name=${shield:+$shield - }${board}
    artifact_name=${shield:+${shield// /-}-}${board}-zmk
    build_dir="build/${artifact_name}"

    echo -e "\nEnvironment:"
    echo "zephyr_version: ${ZEPHYR_VERSION}"
    echo "board: ${board}"
    echo "shield: ${shield}"
    echo "extra_cmake_args: ${extra_cmake_args}"
    echo "display_name: ${display_name}"
    echo "artifact_name: ${artifact_name}"
    echo -e "\n"

    echo -e "Building ${display_name}\n"

    if [[ ! -d "$build_dir" ]]; then
        west build -s zmk/app -b "$board" -d ${build_dir} -- \
            -DZMK_CONFIG="$CONFIG_DIR" "${extra_cmake_args}"
    else
        west build -d ${build_dir}
    fi

    # echo -e "${display_name} KConfig\n"
    # grep -v -e "^#" -e "^$" ${build_dir}/zephyr/.config | sort

    cp ${build_dir}/zephyr/zmk.uf2 "firmware/${TIMESTAMP}-${artifact_name}.uf2"

    chown ${USERID} -R ${build_dir}
done < <(yq '.include[] | [.board, .shield // ""] | @csv' ${BUILD_MATRIX_PATH})

chown ${USERID} firmware/*
