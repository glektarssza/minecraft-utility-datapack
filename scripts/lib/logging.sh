# shellcheck shell=bash

#-- Make errors fatal
set -e;

if [[ -z "${LIB_DIR}" ]]; then
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
) )";
fi

#-- Make errors no longer fatal
set +e;

#-- Sourcing guard
if [[ -n "${__LIB_LOGGING}" ]]; then
    return 0;
fi
declare __LIB_LOGGING="1";

source "${LIB_DIR}/graphics.sh";

if [[ -z "${LIB_LOGGING_DEBUG}" ]]; then
    # Whether to enable verbose logging.
    declare LIB_LOGGING_DEBUG="false";
fi

if [[ -z "${LIB_LOGGING_VERBOSE}" ]]; then
    # Whether to enable verbose logging.
    declare LIB_LOGGING_VERBOSE="false";
fi

# Log a debug-level message.
function log_debug() {
    if [[ ! ( "${LIB_LOGGING_DEBUG}" =~ false\|0 ) ]]; then
        printf "[$(sgr_fg_8bit 220)DEBUG$(sgr_reset)] %s\n" "$*";
    fi
    return 0;
}

# Log a verbose-level message.
function log_verbose() {
    if [[ ! ( "${LIB_LOGGING_VERBOSE}" =~ false\|0 ) ]]; then
        printf "[$(sgr_fg_8bit 171)VERBOSE$(sgr_reset)] %s\n" "$*";
    fi
    return 0;
}

# Log an informational-level message.
function log_info() {
    printf "[$(sgr_fg_8bit 111)INFO$(sgr_reset)] %s\n" "$*";
    return 0;
}

# Log a warning-level message.
function log_warning() {
    printf "[$(sgr_fg_8bit 202)WARN$(sgr_reset)] %s\n" "$*";
    return 0;
}

# Log a warning-level message.
function log_warning_stderr() {
    printf "[$(sgr_fg_8bit 202)WARN$(sgr_reset)] %s\n" "$*" >&2;
    return 0;
}

# Log an error-level message.
function log_error() {
    printf "[$(sgr_fg_8bit 160)ERROR$(sgr_reset)] %s\n" "$*" >&2;
    return 0;
}

# Log an error-level message to the standard output.
function log_error_stdout() {
    printf "[$(sgr_fg_8bit 160)ERROR$(sgr_reset)] %s\n" "$*";
    return 0;
}

# Log a fatal-level message.
function log_fatal() {
    printf "[$(sgr_fg_8bit 15)$(sgr_bg_8bit 196)FATAL$(sgr_reset)] %s\n" "$*" >&2;
    return 0;
}

# Log a fatal-level message to the standard output.
function log_fatal_stdout() {
    printf "[$(sgr_fg_8bit 15)$(sgr_fg_8bit 196)FATAL$(sgr_reset)] %s\n" "$*";
    return 0;
}
