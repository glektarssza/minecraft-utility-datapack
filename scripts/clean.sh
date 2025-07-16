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
    unset SCRIPT_PATH PROJECT_DIR;
}

function cleanup {
    cleanup_vars;
}

#-- Make errors no longer fatal
set +e;

log_info "Starting clean...";

if [[ ! -d "${PROJECT_DIR}/dist/" ]]; then
    log_info "No 'dist' directory, nothing to do!";
    cleanup;
    exit 0;
fi

if [[ -z "$(ls "${PROJECT_DIR}/dist/")" ]]; then
    log_info "Nothing in the 'dist' directory, nothing to do!";
    cleanup;
    exit 0;
fi

log_info "Removing 'zip' files inside  '${PROJECT_DIR}/dist/'...";

#-- Run as a subshell to avoid `cd` impacting our shell
(
cd "${PROJECT_DIR}/dist/";
rm ./*.zip;
)

log_info "Done cleaning";

cleanup;

exit 0;
