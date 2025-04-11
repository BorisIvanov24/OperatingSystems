#!/bin/bash

if [[ "${#}" -ne 2 ]]; then
    echo "Argument count must be 2!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then
    echo "File doesn't exist!"
    exit 2
fi

if [[ -f "${2}" ]]; then
    echo "Output file already exists!"
    exit 3
fi

inFile="${1}"
outFile="${2}"

touch "${outFile}"

while read line1; do

    copies="$(cat "${inFile}" | grep -E "${line1}")"

    if [[ $(echo "${copies}" | wc -l) -gt 1 ]]; then

        smallestId="$(echo "${copies}" | cut -d ',' -f 1 | sort -n | head -n 1)"

        echo "${smallestId}${line1}" >> "${outFile}"

    else
        echo "${copies}" >> "${outFile}"

    fi

done < <(cat "${inFile}" | cut -d ',' -f 1 --complement | awk '{print ","$0}' | sort | uniq)