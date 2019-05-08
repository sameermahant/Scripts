#!/bin/bash
set -eu

# Utility functions to work with 'PATH' environment variable
# ===========================================================

function pathlist {
    if [[ -z "${PATH-}" ]]; then
        echo 'PATH is empty.'
    else
        echo $PATH | tr ":" "\n"
    fi
}

# Ref: https://unix.stackexchange.com/a/282433
function addToPath {

    if [[ $# -eq 0 ]] ; then
        echo 'No argument provided.'
        return 1
    fi

    if [[ $# -ne 1 ]] ; then
        echo 'More than 1 argument are not allowed.'
        return 1
    fi

    if [[ -z "${1// }" ]]; then
        echo 'Empty argument to function.'
        return 1
    fi

    if [[ -z "${PATH-}" ]]; then
        echo 'Adding 1st entry to PATH.'
        PATH="$1"
        return 0
    fi

    # Make sure the entry is not already in path
    case ":$PATH:" in
        *":$1:"*) :;; # already there
        *) PATH="$1:$PATH";; # or PATH="$PATH:$1"
    esac
}

# Ref: https://unix.stackexchange.com/a/291611
function removeFromPath {

    if [[ $# -eq 0 ]] ; then
        echo 'No argument provided.'
        return 1
    fi

    if [[ $# -ne 1 ]] ; then
        echo 'More that 1 argument are not allowed.'
        return 1
    fi

    if [[ -z "${1// }" ]]; then
        echo 'Empty argument to function.'
        return 1
    fi

    if [[ -z "${PATH-}" ]]; then
        echo 'PATH is empty.'
        return 1
    fi

    # Delete path by parts so we can never accidentally remove sub paths
    PATH=${PATH//":$1:"/":"} # delete any instances in the middle
    PATH=${PATH/#"$1:"/} # delete any instance at the beginning
    PATH=${PATH/%":$1"/} # delete any instance in the at the end
}

# Utility functions to work with 'LD_LIBRARY_PATH' environment variable
# ======================================================================

function libpathlist {
    if [[ -z "${LD_LIBRARY_PATH-}" ]]; then
        echo 'LD_LIBRARY_PATH is empty.'
    else
        echo $LD_LIBRARY_PATH | tr ":" "\n"
    fi
}

function addToLibPath {

    if [[ $# -eq 0 ]] ; then
        echo 'No argument provided.'
        return 1
    fi

    if [[ $# -ne 1 ]] ; then
        echo 'More that 1 argument are not allowed.'
        return 1
    fi

    if [[ -z "${1// }" ]]; then
        echo 'Empty argument to function.'
        return 1
    fi

    if [[ -z "${LD_LIBRARY_PATH-}" ]]; then
        echo 'Adding 1st entry to LD_LIBRARY_PATH.'
        LD_LIBRARY_PATH="$1"
        return 0
    fi

    # Make sure the entry is not already in path
    case ":$LD_LIBRARY_PATH:" in
        *":$1:"*) :;; # already there
        *) LD_LIBRARY_PATH="$1:$LD_LIBRARY_PATH";;
    esac
}

function removeFromLibPath {

    if [[ $# -eq 0 ]] ; then
        echo 'No argument provided.'
        return 1
    fi

    if [[ $# -ne 1 ]] ; then
        echo 'More than 1 argument are not allowed.'
        return 1
    fi

    if [[ -z "${1// }" ]]; then
        echo 'Empty argument to function.'
        return 1
    fi

    if [[ -z "${LD_LIBRARY_PATH-}" ]]; then
        echo 'LD_LIBRARY_PATH is empty.'
        return 1
    fi

    LD_LIBRARY_PATH=${LD_LIBRARY_PATH//":$1:"/":"}
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH/#"$1:"/}
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH/%":$1"/}
}
