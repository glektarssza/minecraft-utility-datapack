#!/usr/bin/env bash
# The main build script.

#-- Make errors fatal
set -e;

declare SCRIPT_PATH PROJECT_DIR;
SCRIPT_PATH="$( (
        declare SOURCE_PATH SYMLINK_DIR SCRIPT_DIR;
        # shellcheck disable=SC2296
        if [[ -n "${BASH_SOURCE[0]}" ]]; then
            SOURCE_PATH="${BASH_SOURCE[0]}";
        elif [[ -n "${ZSH_VERSION}" ]]; then
            #-- This is APPARENTLY valid syntax for zsh specifically
            # shellcheck disable=SC2296
            SOURCE_PATH="${(%):-%x}";
        elif [[ -n "${.sh.version}" ]]; then
            #-- This is APPARENTLY valid syntax for ksh specifically
            # shellcheck disable=SC2296
            SOURCE_PATH="${.sh.file}";
        else
            #!! DEAD FINAL TRY
            SOURCE_PATH="$0";
        fi
        while [ -L "${SOURCE_PATH}" ]; do
            SYMLINK_DIR="$(cd -P "$(dirname "${SOURCE_PATH}")" > /dev/null 2>&1 && pwd)";
            SOURCE_PATH="$(readlink "${SOURCE_PATH}")";
            if [[ "${SOURCE_PATH}" != /* ]]; then
                SOURCE_PATH="${SYMLINK_DIR}/${SOURCE_PATH}";
            fi
        done
        SCRIPT_DIR="$(cd -P "$(dirname "${SOURCE_PATH}")" > /dev/null 2>&1 && pwd)";
        echo "${SCRIPT_DIR}";
    )
)";
PROJECT_DIR="${SCRIPT_PATH}/..";

source "${SCRIPT_PATH}/lib/entry.sh";

function cleanup_vars {
    unset SCRIPT_PATH;
}

function cleanup {
    cleanup_vars;
}

trap cleanup EXIT;

#-- Make errors no longer fatal
set +e;

log_info "Starting build...";

log_info "Finding nearest Git tag...";

declare GIT_TAG;
GIT_TAG="$(git rev-parse --abbrev-ref --tags --not HEAD | grep -v '\^')";

if [[ -z "${GIT_TAG}" ]]; then
    log_fatal "Could not find any Git tags!";
    exit 1;
fi

if [[ -z "${CI}" ]]; then
    log_warning "Building in a development environment!";
    GIT_TAG="${GIT_TAG}-dev";
fi

if [[ ! -d "${PROJECT_DIR}/dist/" ]]; then
    log_verbose "Creating 'dist' directory...";
    mkdir -p "${PROJECT_DIR}/dist/";
fi

log_info "Building as version ${GIT_TAG}...";

#-- Run as a subshell to avoid `cd` impacting our shell
(
cd "${PROJECT_DIR}/src/";
zip -r "${PROJECT_DIR}/dist/glek_util_pack-${GIT_TAG}.zip" ".";
)

log_info "Built as version ${GIT_TAG}...";

exit 0;
