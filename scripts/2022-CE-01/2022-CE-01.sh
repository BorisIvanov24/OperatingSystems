#!/bin/bash

if [[ "${#}" -ne 3 ]]; then

    echo "Expected 3 arguments"
    exit 1
fi

if [[ ! "${1}" =~ ^-?(0|[1-9][0-9]*)(\.[0-9]+)?$ ]]; then

    echo "Expected a number"
    exit 7
fi

num="${1}"
prefix="${2}"
unit="${3}"

if [[ ! -f "prefix.csv" ]]; then

    echo "prefix.csv not found"
    exit 2
fi

if [[ ! -f "base.csv" ]]; then

    echo "base.csv not found"
    exit 3
fi

decimal=$(cat "prefix.csv" | grep -E "^[^,]+,${prefix},[0-9.]+$" | cut -d ',' -f3)

if [[ -z "${decimal}" ]]; then

    echo "prefix not found"
    exit 4
fi

measure=$(cat "base.csv" | grep -E "^[^,]+,${unit},[^,]+$" | cut -d ',' -f3)

if [[ -z "${measure}" ]]; then

    echo "measure not found"
    exit 5
fi

name=$(cat "base.csv" | grep -E "^[^,]+,${unit},[^,]+$" | cut -d ',' -f1)

if [[ -z "${name}" ]]; then

    echo "name not found"
    exit 6
fi

res=$(echo "${num} * ${decimal}" | bc)
res=$(echo "${res}" | sed -E 's/^(-?)(\.[0-9]+)$/\10\2/g')
echo "${res} ${unit} (${measure}, ${name})"