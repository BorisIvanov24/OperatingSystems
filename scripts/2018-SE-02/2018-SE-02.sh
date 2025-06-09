#!/bin/bash

if [[ "${#}" -ne 2 ]]; then

    echo "Arguments must be 2!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then

    echo "Argument must be a file!"
    exit 2
fi

if [[ ! -d "${2}" ]]; then

    echo "Argument must be a directory!"
    exit 3
fi

names=$(mktemp)
map=$(mktemp)

cat "${1}" | sed -E 's/(^([a-zA-Z-]+) *([a-zA-Z-]+)).*:.*$/\1/g' | sort | uniq >> "${names}"

index="1"

while read name; do

    echo "${name};${index}" >> "${map}"

    touch "${2}/${index}.txt"

    cat "${1}" | grep -E "^${name}.*$" >> "${2}/${index}.txt"

    index=$(echo "${index} + 1" | bc)

done< <(cat "${names}")

touch "${2}/dict.txt"

cat "${map}" | tr -s ' ' >> "${2}/dict.txt"

rm "${names}" "${map}"
