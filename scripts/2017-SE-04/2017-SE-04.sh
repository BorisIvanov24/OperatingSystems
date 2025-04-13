#!/bin/bash

if [[ "${#}" -ne 1 && "${#}" -ne 2 ]]; then
    echo "Arguments count must be 1 or 2!"
    exit 1
fi

if [[ ! -d "${1}" ]]; then
   echo "Argument must be a valid directory!"
   exit 2
fi

if [[ "${#}" -eq 2 && -e "${2}" ]]; then
    echo "File already exists!"
    exit 3
fi

tempOut=$(mktemp)
symlinks=$(mktemp)
brokenSymLinks=0

find "${1}" -type l > "${symlinks}"

while read symlink; do

    target=$(readlink -f "${symlink}")

    if [[ ! -e "${target}" ]]; then
        brokenSymLinks=$(("${brokenSymLinks}" + 1))
        continue
    fi

    echo "${symlink} -> ${target}" >> "${tempOut}"
done < <(cat "${symlinks}")

echo "broken symlinks: ${brokenSymLinks}" >> "${tempOut}"

if [[ "${#}" -eq 1 ]]; then
    cat "${tempOut}"

else
    cat "${tempOut}" > "${2}"
fi

rm "${tempOut}" "${symlinks}"