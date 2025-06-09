#!/bin/bash

if [[ "${#}" -ne 1 ]]; then

    echo "Arguments must be one!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then

    echo "Argument must be a file!"
    exit 2
fi

allSites=$(mktemp)
sites=$(mktemp)
top3Sites=$(mktemp)
answer=$(mktemp)
users=$(mktemp)
usersTable=$(mktemp)

cat "${1}" | sed -E "s/^[0-9.]+ (.*) .* \[.*\] (GET|POST).*$/\1/g" | sort | uniq >> "${allSites}"

while read site; do

    num=$(cat "${1}" | grep -E "^[0-9.]+ ${site} .* \[.*\] (GET|POST).*$" | wc -l)
    echo "${site} ${num}" >> "${sites}"

done< <(cat "${allSites}")

cat "${sites}" | sort -n -r -k2 | head -n 3 | cut -d ' ' -f1 >> "${top3Sites}"

while read site; do

    http2=$(cat "${1}" | grep -E "^[0-9.]+ ${site} .* \[.*\] (GET|POST).*HTTP/2\.0.*$" | wc -l)
    http1=$(cat "${1}" | grep -E "^[0-9.]+ ${site} .* \[.*\] (GET|POST).*HTTP/(1\.1|1\.0).*$" | wc -l)

    echo "${site} HTTP/2.0: ${http2} non-HTTP/2.0: ${http1}"

    cat "${1}" | grep -E "^([0-9.]+) ${site} .*$" | cut -d ' ' -f1 | sort | uniq > "${users}"

    while read user; do

        num=$(cat "${1}" | grep -E "^${user} ${site} .* \[.*\] (GET|POST).*HTTP/(2\.0|1\.1|1\.0) (30[3-9]|3[1-9][0-9]|[4-9][0-9][0-9]) .*$" | wc -l)

        if [[ "${num}" -gt 0 ]]; then
            echo "   ${num} ${user}" >> "${usersTable}"
        fi

    done< <(cat "${users}")

    cat "${usersTable}" | sort -n -r -k1 | head -n 5

done< <(cat "${top3Sites}")

rm "${allSites}" "${users}" "${usersTable}" "${sites}" "${top3Sites}" "${answer}"