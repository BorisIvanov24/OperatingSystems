#!/bin/bash

if [[ "${#}" -ne 3 ]]; then
    echo "Arguments count must be 3!"
    exit 1
fi

if [[ ! -d "${1}" ]]; then
    echo "First argument must be a directory!"
    exit 2
fi

if [[ ! -d "${2}" ]]; then
    echo "Second argument must be a directory!"
    exit 3
fi

if [ $(find "${2}" -mindepth 1 -print -quit) ]; then
    echo "Second argument must be an empty directory!"
    exit 4
fi

if [[ "${UID}" -ne 0 ]]; then
    echo "You need to be root to run this command!"
    exit 5
fi

SRC="${1}"
DST="${2}"
STR="${3}"

files=$(mktemp)

find "${SRC}" -type f -print > "${files}"

while read file; do

if echo "$(basename "${file}")" | grep -q "${STR}"; then
    newName=$(echo "${file}" | sed -E "s/^${SRC}\/(.*$)/${DST}\/\1/")

    mkdir -p "$(dirname ${newName})"
    mv "${file}" "${newName}"
fi

done < <(cat "${files}")

rm "${files}"