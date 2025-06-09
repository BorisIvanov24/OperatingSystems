#!/bin/bash

if [[ "${#}" -eq 0 ]]; then

    echo "Arguments must be greater than 0!"
    exit 1
fi

N="10"

if [[ "${1}" == "-n" ]]; then

    if [[ "${#}" -lt 3 ]]; then

        echo "Invalid arguments"
        exit 2
    fi

    if ! [[ "${2}" =~ ^(0|[1-9][0-9]*)$ ]]; then

        echo "Invalid arguments"
        exit 3
    fi

    N="${2}"
fi

answer=$(mktemp)

while read file; do

    if [[ ! -f "${file}" ]]; then
        continue
    fi

    echo "${file}"

    IDF=$( echo "${file}" | sed -E 's/(^.*)\.log$/\1/g' )

    escapedIDF=$(echo "${IDF}" | sed 's/\//\\\//g')

    cat "${file}" | tail -n "${N}" | sed -E "s/^([0-9-]+ [0-9:]+) (.*)$/\1 ${escapedIDF} \2/g" >> "${answer}"

done< <(printf "%s\n" "${@}")

cat "${answer}" | sort -k1,2

rm "${answer}"