#!/usr/bin/env bash

SCRIPT_SOURCE="${BASH_SOURCE[0]}";

while [[ -L "${SCRIPT_SOURCE}" ]]; do
  SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_SOURCE}")" > /dev/null 2>&1 && pwd)";
  SCRIPT_SOURCE=$(readlink "${SCRIPT_SOURCE}");
  [[ "${SCRIPT_SOURCE}" != /* ]] && SCRIPT_SOURCE="${SCRIPT_DIR}/${SCRIPT_SOURCE}";
done

SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_SOURCE}")" > /dev/null 2>&1 && pwd)";

VERSION_TAG="$1"

if [[ -z "${VERSION_TAG}" ]]; then
    printf "[\x1b[38;5;208mWARN\x1b[0m] No version tag provided, falling back to Git commit!\n";
    VERSION_TAG="$(git rev-parse --short HEAD)";
fi

PROJECT_ROOT="$(cd -P "${SCRIPT_DIR}/.." > /dev/null 2>&1 && pwd)";
SOURCE_DIR="${PROJECT_ROOT}/src";
DIST_DIR="${PROJECT_ROOT}/dist";
OUTPUT_FILE="${DIST_DIR}/glek-utils-${VERSION_TAG}.zip";

ZIP_EXEC="$(which zip 2> /dev/null)"

if [[ ! -f "${ZIP_EXEC}" ]]; then
    printf "[\x1b[38;5;160mERROR\x1b[0m] Failed to locate 'zip' executable!\n";
    printf "\x1b[38;5;160mFAILURE\x1b[0m\n";
    exit 1;
fi

if [[ ! -d "${SOURCE_DIR}" ]]; then
    printf "[\x1b[38;5;160mERROR\x1b[0m] Failed to locate source directory!\n";
    printf "\x1b[38;5;160mFAILURE\x1b[0m\n";
    exit 1;
fi

if [[ ! -d "${DIST_DIR}" ]]; then
    printf "[\x1b[38;5;111mINFO\x1b[0m] Output directory does not exist, creating...\n";
    mkdir -p "${DIST_DIR}";
    if [[ $? != 0 ]]; then
        printf "[\x1b[38;5;160mERROR\x1b[0m] Failed to create output directory!\n";
        printf "\x1b[38;5;160mFAILURE\x1b[0m\n";
        exit 1;
    fi
fi

if [[ -f "${OUTPUT_FILE}" ]]; then
    printf "[\x1b[38;5;208mWARN\x1b[0m] Output file already exists, removing...\n";
    rm "${OUTPUT_FILE}";
    if [[ $? != 0 ]]; then
        printf "[\x1b[38;5;160mERROR\x1b[0m] Failed to remove existing output file!\n";
        printf "\x1b[38;5;160mFAILURE\x1b[0m\n";
        exit 1;
    fi
fi

printf "[\x1b[38;5;111mINFO\x1b[0m] Building datapack for version '${VERSION_TAG}'...\n";
printf "[\x1b[38;5;111mINFO\x1b[0m] Creating datapack at '${OUTPUT_FILE}'...\n";

pushd "${SOURCE_DIR}" > /dev/null 2>&1;

zip -n ".png" -r -9 "${OUTPUT_FILE}" "." > /dev/null 2>&1;

popd > /dev/null 2>&1;

if [[ $? != 0 ]]; then
    printf "[\x1b[38;5;160mERROR\x1b[0m] Failed to create datapack!\n";
    printf "\x1b[38;5;160mFAILURE\x1b[0m\n";
    exit 1;
fi

printf "[\x1b[38;5;111mINFO\x1b[0m] Built datapack\n";
printf "\x1b[38;5;76mSUCCESS\x1b[0m\n";
exit 0;
