#!/usr/bin/env bash

config_dir="${PWD}/config"
timestamp=$(date -u +"%Y%m%d%H%M%S")

while IFS=$',' read -r board shield; do
	extra_cmake_args=${shield:+-DSHIELD="$shield"}
	# "${molock:+-DUSE_MOLOCK="$molock"}"
	artifact_name=${shield:+${shield// /-}-}${board}-zmk
	filename="${PWD}/firmware/${timestamp}-${artifact_name}"
	build_dir="${PWD}/build/${artifact_name}"

	echo ""
	echo "-----------------"
	echo "BUILDING FIRMWARE"
	echo "-----------------"
	echo "Zephyr: ${ZEPHYR_VERSION}"
	echo "Board: ${board}"
	echo "Shield: ${shield}"
	echo ""

	if [[ ! -d "$build_dir" ]]; then
		build_dir="${PWD}/build" &&
			west build -p -s zmk/app -b "$board" -d "$build_dir/corne-left" -- \
				-DSHIELD=corne_left \
				-DDTS_EXTRA_CPPFLAGS="-DUSE_MOLOCK=1" \
				-DZMK_CONFIG="$config_dir" "$extra_cmake_args" &&
			west build -p -s zmk/app -b "$board" -d "$build_dir/corne-right" -- \
				-DSHIELD=corne_right \
				-DDTS_EXTRA_CPPFLAGS="-DUSE_MOLOCK=1" \
				-DZMK_CONFIG="$config_dir" "$extra_cmake_args" &&
			west build -p -s zmk/app -b "$board" -d "$build_dir/settings-reset" -- \
				-DSHIELD="settings_reset" \
				-DZMK_CONFIG="$config_dir" "$extra_cmake_args"

	else
		build_dir=""$PWD/build &&
			west build -d "$build_dir/corne_left" &&
			west build -d "$build_dir/corne_right" &&
			west build -d "$build_dir/settings_reset"
	fi

	if [[ ! -z $OUTPUT_ZMK_CONFIG ]]; then
		grep -v -e "^#" -e "^$" "$build_dir"/zephyr/.config |
			sort >"${filename}.config"
	fi

	extensions="uf2 hex bin"
	for extension in "${extensions[@]}"; do
		artifact=${build_dir}/zephyr/zmk.$extension
		if [[ -f $artifact ]]; then
			cp "$artifact" "${filename}.$extension"
			break
		fi
	done
done < <(yq '
    [{"board": .board[], "shield": .shield[] // ""}] + .include
    | filter(.board)
    | unique_by(.board + .shield).[]
    | [.board, .shield // ""]
    | @csv
' build.yaml)
