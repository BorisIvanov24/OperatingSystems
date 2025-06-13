#!/bin/bash

if [[ "${#}" -ne 2 ]]; then

    echo "Expected 2 arguments!"
    exit 1
fi

if [[ ! -d "${1}" ]]; then

    echo "Expected a directory!"
    exit 2
fi

SRC="${1}"
DST="${2}"

mkdir -p "${DST}/images"

while read file; do

    title=$(basename "${file}" .jpg | sed -E "s/\([^)]*\)/ /g" | sed -E "s/(^[[:space:]]+)|([[:space:]]+$)//g" | tr -s ' ')

    album=$(basename "${file}" .jpg | sed -n -E "s/\(([^()]*)\)[^()]*$/\1/p" | sed -E "s/(^[[:space:]]+)|([[:space:]]+$)//g" | tr -s ' ')

    if [[ -z "${album}" ]]; then

        album="misc"
    fi

    date=$(printf "%(%Y-%m%d)T" $(stat -c %Y "${file}"))

    hash=$(sha256sum "${file}" | cut -d ' ' -f1 | sed -n -E 's/^(.{16}).*$/\1/p')

    cp "${file}" "${DST}/images/${hash}.jpg"

    mkdir -p "${DST}/by-date/${date}/by-album/${album}/by-title"
    ln -s "${file}" "${DST}/by-date/${date}/by-album/${album}/by-title/${title}.jpg"

    mkdir -p "${DST}/by-date/${date}/by-title"
    ln -s "${file}" "${DST}/by-date/${date}/by-title/${title}.jpg"

    mkdir -p "${DST}/by-album/${album}/by-date/${date}/by-title"
    ln -s "${file}" "${DST}/by-album/${album}/by-date/${date}/by-title/${title}.jpg"

    mkdir -p "${DST}/by-album/${album}/by-title"
    ln -s "${file}" "${DST}/by-album/${album}/by-title/${title}.jpg"

    mkdir -p "${DST}/by-title"
    ln -s "${file}" "${DST}/by-title/${title}.jpg"

done< <(find "${SRC}" -type f | grep -E "^.*\.jpg$")
