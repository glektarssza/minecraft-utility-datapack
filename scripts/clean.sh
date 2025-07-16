#!/usr/bin/env bash
# The main clean script.

#-- Make errors fatal
set -e;

declare SCRIPT_PATH PROJECT_DIR TRUE FALSE DRY_RUN;
declare LIB_LOGGING_VERBOSE LIB_LOGGING_DEBUG;

TRUE="true";
FALSE="false";

LIB_LOGGING_VERBOSE="${VERBOSE}";
LIB_LOGGING_DEBUG="${DEBUG}";
DRY_RUN="${FALSE}";

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
    unset SCRIPT_PATH PROJECT_DIR TRUE FALSE DRY_RUN;
    unset LIB_LOGGING_VERBOSE LIB_LOGGING_DEBUG ;
}

function cleanup {
    cleanup_vars;
}

function print_epilogue {
    echo "Copyright (c) 2025 G'lek Tarssza, all rights reserved.";
}

function print_help {
    echo "clean.sh [options] [args]";
    echo "Clean old built versions of the datapack.";
    echo "";
    echo "=== Arguments ===";
    echo "";
    echo "=== Options ===";
    printf "  --help|-h\t\t\t\tShow the help information and then exit.\n";
    printf "  --version\t\t\t\tShow the version information and then exit.\n";
    printf "  --verbose|-v\t\t\t\tEnable verbose logging.\n";
    printf "  --no-verbose\t\t\t\tDisable verbose logging.\n";
    printf "  --debug|-d\t\t\t\tEnable debug logging.\n";
    printf "  --no-debug\t\t\t\tDisable debug logging.\n";
    printf "  --dry-run\t\t\t\tOnly print what operations would have been performed.\n";
    echo "";
    print_epilogue;
}

function print_version {
    printf "v0.0.1 - ";
    print_epilogue;
}

function parse_args {
    while [[ -n "${1+set}" ]]; do
        case "$1" in
            --help|-h)
                print_help;
                exit 0;
            ;;
            --version)
                print_version;
                exit 0;
            ;;
            --verbose|-v)
                # shellcheck disable=SC2034
                LIB_LOGGING_VERBOSE="${TRUE}";
                log_verbose "Verbose logging enabled";
            ;;
            --no-verbose)
                log_verbose "Disabling verbose logging...";
                # shellcheck disable=SC2034
                LIB_LOGGING_VERBOSE="${FALSE}";
            ;;
            --debug|-d)
                # shellcheck disable=SC2034
                LIB_LOGGING_DEBUG="${TRUE}";
                log_debug "Debug logging enabled";
            ;;
            --no-debug)
                log_debug "Disabling debug logging...";
                # shellcheck disable=SC2034
                LIB_LOGGING_DEBUG="${FALSE}";
            ;;
            --dry-run)
                DRY_RUN="${TRUE}";
                log_verbose "Dry run mode enabled";
            ;;
            '')
                #-- Does nothing!
            ;;
            *)
                log_fatal "Unrecognized option '$1'!";
                cleanup;
                exit 1;
            ;;
        esac
        shift;
    done
}

#-- Make errors no longer fatal
set +e;

parse_args "$@";

if [[ ! -d "${PROJECT_DIR}/dist/" ]]; then
    log_info "'dist' directory does not exist, nothing to do!";
    cleanup;
    exit 0;
fi

if [[ -z "$(ls "${PROJECT_DIR}/dist/")" ]]; then
    log_info "'dist' directory is empty, nothing to do!";
    cleanup;
    exit 0;
fi

log_info "Cleaning old versions...";

for ARCHIVE in "${PROJECT_DIR}"/dist/*.zip; do
    log_info "Deleting '$(basename "${ARCHIVE}")'...";
    if [[ "${DRY_RUN}" == "${FALSE}" ]]; then
        rm "${ARCHIVE}";
    else
        log_info "Would have run:";
        log_info "rm \"\${ARCHIVE}\";";
    fi
done

log_info "Cleaned old versions";

cleanup;

exit 0;
