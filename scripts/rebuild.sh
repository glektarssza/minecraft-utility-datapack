#!/usr/bin/env bash
# The main rebuild script.

#-- Make errors fatal
set -e;

declare SCRIPT_PATH;
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

source "${SCRIPT_PATH}/lib/entry.sh";

function cleanup_vars {
    unset SCRIPT_PATH PROJECT_DIR;
}

function cleanup {
    cleanup_vars;
}

#-- Make errors no longer fatal
set +e;

"${SCRIPT_PATH}/clean.sh";
if [[ ! $? ]]; then
    log_fatal "Failed to clean old outputs!";
    cleanup
    exit 1;
fi

"${SCRIPT_PATH}/build.sh";
if [[ ! $? ]]; then
    log_fatal "Failed to build!";
    cleanup
    exit 1;
fi

exit 0;
