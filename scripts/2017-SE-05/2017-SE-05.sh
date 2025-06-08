#!/bin/bash

if [[ "${#}" -ne 2 ]]; then

    echo "Invalid number of arguments"
    exit 1
fi

if [[ ! -d "${1}" ]]; then

    echo "First argument must be a directory!"
    exit 2
fi

files=$(mktemp)

find "${1}" -maxdepth 1 -type f -printf "%f\n" 2>/dev/null | grep -E "^vmlinuz-(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)-${2}$" >> "${files}"

cat "${files}" | sed -E "s/^(vmlinuz-(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)-${2})$/\1:\2:\3:\4/" | sort -t: -k2,2n -k3,3n -k4,4n | tail -n 1 | cut -d':' -f1

rm "${files}"