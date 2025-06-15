#!/bin/bash

if [[ "${#}" -ne 2 ]]; then

    echo "Expected 2 arguments"
    exit 1
fi

if [[ ! -d "${1}" ]]; then

    echo "Expected a dir"
    exit 2
fi

if [[ -n "$(ls -A ${2})" ]]; then

    echo "Expected empty dir"
    exit 3
fi

files=$(mktemp)

find "${1}" -type f | grep -v -E '.*/\..*\.swp$' >> "${files}"

while read file; do

    file=$(echo "${file}" | sed -E "s/^${1}(.*)$/\1/")

    echo "${file}"

    dir=$(dirname "${file}")

    echo "${dir}"

    mkdir -p "${2}/${dir}"

    echo "${1}/${file} ${2}/${file}"
    cp "${1}/${file}" "${2}/${file}"

done< <(cat "${files}")

rm "${files}"
