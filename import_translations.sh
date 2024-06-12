#!/usr/bin/env bash

local_resources_dir="/Users/sergi/chordify/android-app/app/src/main/res"
zipped_file=$@

tmp_dir=$(mktemp -d)

unzip "$zipped_file" -d $tmp_dir || exit 1

ls $tmp_dir

supported_locale_suffixes=("" "-es" "-nl" "-fr" "-de" "-it" "-pt-rBR")

for locale_suffix in "${supported_locale_suffixes[@]}"; do
	strings_to_import_path="$tmp_dir/values$locale_suffix/strings.xml"
	android_values_path="$local_resources_dir/values$locale_suffix"
	ls "$android_values_path"
	cp -f "$strings_to_import_path" "$android_values_path"
done

rm -rf $tmp_dir