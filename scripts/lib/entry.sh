# shellcheck shell=bash
# The main entry point into the utility script library.

#-- Make errors fatal
set -e;

declare LIB_DIR;
LIB_DIR="$( (
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

source "${LIB_DIR}/graphics.sh";
source "${LIB_DIR}/logging.sh";

#-- Make errors no longer fatal
set +e;
