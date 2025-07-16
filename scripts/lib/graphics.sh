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
if [[ -n "${__LIB_GRAPHICS}" ]]; then
    return 0;
fi
declare __LIB_GRAPHICS="1";

# Output the Control Sequence Indication prefix.
function csi_prefix() {
    printf "\x1b[";
    return 0;
}

# Output a Select Graphics Rendition command.
function sgr_command() {
    printf "%s%sm" "$(csi_prefix)" "$1";
    return 0;
}

# Output the reset graphics command.
function sgr_reset() {
    sgr_command 0;
    return 0;
}

# Output the bold graphics command.
function sgr_bold() {
    sgr_command 1;
    return 0;
}

# Output the faint graphics command.
function sgr_faint() {
    sgr_command 2;
    return 0;
}

# Output the italic graphics command.
function sgr_italic() {
    sgr_command 3;
    return 0;
}

# TODO: Other SGR codes

function sgr_fg_8bit() {
    if [[ $1 -lt 0 || $1 -gt 255 ]]; then
        return 1;
    fi
    sgr_command "38;5;$1";
    return 0;
}

function sgr_bg_8bit() {
    if [[ $1 -lt 0 || $1 -gt 255 ]]; then
        return 1;
    fi
    sgr_command "48;5;$1";
    return 0;
}

function sgr_fg_24bit() {
    if [[ $1 -lt 0 || $1 -gt 255 ]]; then
        return 1;
    fi
    if [[ $2 -lt 0 || $2 -gt 255 ]]; then
        return 1;
    fi
    if [[ $3 -lt 0 || $3 -gt 255 ]]; then
        return 1;
    fi
    sgr_command "38;2;$1;$2;$3";
    return 0;
}

function sgr_bg_24bit() {
    if [[ $1 -lt 0 || $1 -gt 255 ]]; then
        return 1;
    fi
    if [[ $2 -lt 0 || $2 -gt 255 ]]; then
        return 1;
    fi
    if [[ $3 -lt 0 || $3 -gt 255 ]]; then
        return 1;
    fi
    sgr_command "48;2;$1;$2;$3";
    return 0;
}

# TODO: Other SGR codes
