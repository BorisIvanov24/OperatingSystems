#!/bin/bash

if [[ "${#}" -ne 1 ]]; then

    echo "Arguments must be one!"
    exit 1
fi

if [[ ! -d "${1}" ]]; then

    echo "Argument must be a directory!"
    exit 2
fi

friends=$(mktemp)
result=$(mktemp)

dir_escaped=$(echo "${1}" | sed 's/\//\\\//g')

find "${1}" -mindepth 3 -maxdepth 3 -type d 2>/dev/null | sed -E "s/^${dir_escaped}\/(.*)$/\1/" | cut -d '/' -f3 | sort | uniq  >>  "${friends}"

while read friend; do

sum=$(find "${1}" -type f 2>/dev/null | grep -E "^${1}/.*/.*/${friend}/.*\.txt$" | xargs cat | wc -l)

echo "${friend} ${sum}" >> "${result}"

done < <(cat "${friends}")

cat "${result}" | sort -k2,2nr | head -n 10

rm "${friends}" "${result}"