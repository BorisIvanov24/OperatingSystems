#!/bin/bash

if [[ "${#}" -ne 0 ]]; then
    echo "Argument count must be 0"
    exit 1
fi

firstIter=0
min=0
max=0

while read line num; do

    if [[ ! "${line}" =~ ^-?(0|[1-9][0-9]*)$ ]]; then
        continue
    fi

    if [[ "${firstIter}" -eq 0 ]]; then
        min="${line}"
        max="${line}"
        firstIter=1
    else
        if [[ "${line}" -gt max ]]; then
            max="${line}"
        fi

        if [[ "${line}" -lt min ]]; then
            min="${line}"
        fi
    fi
done

echo -e "${min}\n${max}"
