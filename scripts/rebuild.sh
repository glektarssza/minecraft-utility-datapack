#!/usr/bin/env bash
# The main rebuild script.

#-- Make errors fatal
set -e;

declare SCRIPT_PATH PROJECT_DIR BUILD_TAG BUILD_CONFIG TRUE FALSE;
declare LIB_LOGGING_VERBOSE LIB_LOGGING_DEBUG DRY_RUN;
declare -a CLEAN_ARGS BUILD_ARGS;

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

BUILD_TAG="$(git rev-parse --short HEAD)";
BUILD_CONFIG="dev";

if [[ -n "${CI}" ]]; then
    BUILD_CONFIG="prod";
fi

function cleanup_vars {
    unset SCRIPT_PATH PROJECT_DIR BUILD_TAG BUILD_CONFIG TRUE FALSE;
    unset LIB_LOGGING_VERBOSE LIB_LOGGING_DEBUG DRY_RUN CLEAN_ARGS BUILD_ARGS;
}

function cleanup {
    cleanup_vars;
}

function print_epilogue {
    echo "Copyright (c) 2025 G'lek Tarssza, all rights reserved.";
}

function print_help {
    echo "rebuild.sh [options] [args]";
    echo "Rebuild the datapack.";
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
    printf "  --build-config|-c [config=dev|prod]\tThe type of build to create.\n";
    printf "    Default: %s\n" "${BUILD_CONFIG}"
    printf "  --build-tag|-t [version]\t\tThe version tag of the build to create.\n";
    printf "    Default: %s\n" "${BUILD_TAG}";
    echo "";
    print_epilogue;
}

function print_version {
    printf "v0.0.1 - ";
    print_epilogue;
}

function parse_args {
    while [[ -n "$1" ]]; do
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
            --build-config|-c)
                shift;
                BUILD_CONFIG="$1";
                if [[ "${BUILD_CONFIG}" != "dev" && "${BUILD_CONFIG}" != "prod" ]]; then
                    log_fatal "Unrecognized build config '${BUILD_CONFIG}'!";
                    cleanup;
                    exit 1;
                fi
                log_debug "Build config set to '${BUILD_CONFIG}'";
            ;;
            --build-config=*|-c=*)
                BUILD_CONFIG="$(echo "$1" | awk -F'=' '{printf $2; for (i = 3; i < NF; i += 1) {printf "="; printf $i;} printf "\n"}')";
                if [[ "${BUILD_CONFIG}" != "dev" && "${BUILD_CONFIG}" != "prod" ]]; then
                    log_fatal "Unrecognized build config '${BUILD_CONFIG}'!";
                    cleanup;
                    exit 1;
                fi
                log_debug "Build config set to '${BUILD_CONFIG}'";
            ;;
            --build-tag|-t)
                shift;
                BUILD_TAG="$1";
                log_debug "Build tag set to '${BUILD_TAG}'";
            ;;
            --build-tag=*|-t=*)
                BUILD_TAG="$(echo "$1" | awk -F'=' '{printf $2; for (i = 3; i < NF; i += 1) {printf "="; printf $i;} printf "\n"}')";
                log_debug "Build tag set to '${BUILD_TAG}'";
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

CLEAN_ARGS=(
    "$([[ "${LIB_LOGGING_VERBOSE}" == "${TRUE}" ]] && echo "--verbose" || echo "--no-verbose")"
    "$([[ "${LIB_LOGGING_DEBUG}" == "${TRUE}" ]] && echo "--debug" || echo "--no-debug")"
);

if [[ "${DRY_RUN}" == "${TRUE}" ]]; then
    CLEAN_ARGS+=("--dry-run");
fi

"${PROJECT_DIR}/scripts/clean.sh" "${CLEAN_ARGS[@]}";
if [[ ! $? ]]; then
    log_fatal "Failed to run 'clean.sh'!";
    cleanup;
    exit 1;
fi

BUILD_ARGS=(
    "$([[ "${LIB_LOGGING_VERBOSE}" == "${TRUE}" ]] && echo "--verbose" || echo "--no-verbose")"
    "$([[ "${LIB_LOGGING_DEBUG}" == "${TRUE}" ]] && echo "--debug" || echo "--no-debug")"
    "--build-config=${BUILD_CONFIG}" "--build-tag=${BUILD_TAG}"
);

if [[ "${DRY_RUN}" == "${TRUE}" ]]; then
    BUILD_ARGS+=("--dry-run");
fi

"${PROJECT_DIR}/scripts/build.sh" "${BUILD_ARGS[@]}";
if [[ ! $? ]]; then
    log_fatal "Failed to run 'build.sh'!";
    cleanup;
    exit 1;
fi

cleanup;

exit 0;
