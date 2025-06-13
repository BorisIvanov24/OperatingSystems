#!/bin/bash

if [[ "${#}" -ne 2 ]]; then
    echo "Arguments must be 2!"
    exit 1
fi

repoDir="$1"
packageDir="$2"

if [[ ! -d "$repoDir" ]]; then
    echo "First argument must be a directory!"
    exit 2
fi

if [[ ! -d "$packageDir" ]]; then
    echo "Second argument must be a directory!"
    exit 3
fi

packageName=$(basename "$packageDir")

if [[ ! -f "${packageDir}/version" ]]; then
    echo "Version file doesn't exist!"
    exit 4
fi

if [[ ! -d "${packageDir}/tree" ]]; then
    echo "Tree directory doesn't exist!"
    exit 5
fi

if [[ ! -f "${repoDir}/db" ]]; then
    echo "db file doesn't exist!"
    exit 6
fi

packageVersion=$(cat "${packageDir}/version")
packageID="${packageName}-${packageVersion}"

archive=$(mktemp)

tar -c -J -f "$archive" -C "${packageDir}/tree" .

sum=$(sha256sum "$archive" | cut -d ' ' -f1)

# Check if version exists
oldSum=$(grep -E "^${packageID} " "${repoDir}/db" | cut -d ' ' -f2)

if [[ -n "$oldSum" ]]; then
    # We need to swap the old one
    sed -i "s/^${packageID} ${oldSum}$/${packageID} ${sum}/" "${repoDir}/db"
    rm -f "${repoDir}/packages/${oldSum}.tar.xz"
    mv "$archive" "${repoDir}/packages/${sum}.tar.xz"
else
    # We add new
    echo "${packageID} ${sum}" >> "${repoDir}/db"
    sort -o "${repoDir}/db" "${repoDir}/db"
    mv "$archive" "${repoDir}/packages/${sum}.tar.xz"
fi