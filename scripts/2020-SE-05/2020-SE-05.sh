#!/bin/bash

if [[ "${#}" -ne 3 ]]; then

    echo "Expected 3 arguments!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then

    echo "Expected a file!"
    exit 2
fi

if [[ ! -d "${3}" ]]; then

    echo "Expected a directory"
    exit 3
fi

if [[ -f "${2}" ]]; then

    echo "File already exists!"
    exit 4
fi

lines=$(mktemp)
errorMsg=$(mktemp)
correctFiles=$(mktemp)

while read file; do

    cat "${file}" > "${lines}"

    index="1"

    echo "Error in ${file}:" > "${errorMsg}"

    while read line; do

        if ! echo "${line}" | grep -E -q "^({ no-production };)|({ volatile };)|({ run-all; };)|(#.*)$" ; then

            echo "Line ${index}:${line}" >> "${errorMsg}"
        fi

        index=$(echo "${index} + 1" | bc)

    done< <(cat "${lines}")

    if [[ $(cat "${errorMsg}" | wc -l) -ne 1 ]]; then

        cat "${errorMsg}"
    else
        cat "${file}" >> "${correctFiles}"

        username=$(basename "${file}" .cfg)

        if ! cat "${1}" | grep -E "^${username}:.*$" ; then

            password=$(pwgen 16 1)
            hash=$(echo -n "${password}" | md5sum | cut -d ' ' -f1)
            echo "${username}:${hash}"
            echo "${username}:${hash}" >> "${1}"
        fi
    fi

done< <(find "${3}" -type f -name '*.cfg')

if [[ $(cat "${correctFiles}" | wc -l) -ne 0 ]]; then

    touch "${2}"
    cat "${correctFiles}" >> "${2}"
fi

rm "${lines}" "${errorMsg}" "${correctFiles}"
