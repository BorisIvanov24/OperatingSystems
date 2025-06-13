#!/bin/bash

if [[ "${#}" -ne 2 ]]; then

    echo "Expected 2 arguments"
    exit 1
fi

if [[ ! -f "${1}" ]]; then

    echo "Expected a file"
    exit 2
fi

if [[ -f "${2}" ]]; then

    echo "File exists"
    exit 3
fi

arrSize=$(($(stat -c "%s" "${1}") / 2))

if [[ "${arrSize}" -gt "524288" ]]; then

    echo "Too much elements in input file"
    exit 4
fi

touch "${2}"

echo "#include <stdint.h>" >> "${2}"
echo "const uint32 arrN = ${arrSize};" >> "${2}"
echo "const uint16 arr[] = {" >> "${2}"

linesNum=$(xxd -g 2 "${1}" | cut -d ' ' -f2-9 | wc -l)
br="1"

while read line; do

    line=$(echo "${line}" | sed -E -e 's/[[:space:]]/, /g' -e 's/([a-z0-9]{4})/0x\1/g')

    if [[ "${br}" -ne "${linesNum}" ]]; then

        line=$(echo "${line}" | sed -E 's/^.*$/&,/')
    fi

    echo "${line}" >> "${2}"

    br=$((br + 1))

done< <(xxd -g 2 "${1}" | cut -d ' ' -f2-9)

echo "};" >> "${2}"