#!/bin/bash

if [[ "${#}" -ne 0 ]]; then
    echo "Argument count must be 0!"
    exit 1
fi

firstIter=0
minNum=0
maxSum=0

while read line; do

    if [[ ! "${line}" =~ ^-?(0|[1-9][0-9]*)$ ]]; then
        continue
    fi

    sum=$(echo "${line}" | tr -d "-" | sed -E "s/(.)/\1+/g" | sed -E "s/\+$//" | bc)

    if [[ "${firstIter}" -eq 0 ]]; then
        minNum="${line}"
        maxSum="${sum}"
        firstIter=1
    else
        if [[ "${sum}" -gt "${maxSum}" ]]; then
            maxSum="${sum}"
            minNum="${line}"
        fi

        if [[ "${sum}" -eq "${maxSum}" ]]; then

            if [[ "${line}" -lt "${minNum}" ]]; then
                minNum="${line}"
            fi
        fi

    fi
done

echo "${minNum}"
