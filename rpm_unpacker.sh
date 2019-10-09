#!/bin/bash
# Modified: 12/10/2018
# Author: Alex Nash 
#
# Purpose: Unpack any number of RPMs quickly and cleanly
#
################################################################################
# GLOBAL VARIABLES:
SCRIPT_NAME="$(basename "${0}")"
DEPENDENCIES=( "rpm2cpio" "cpio" )
VERBOSE=0
RPM_LIST=()

################################################################################
# LOCAL FUNCTION: usage()
# PURPOSE: print out usage to stdout describing
#          how to run this program.

usage() {
cat <<USAGE
NAME
        ${SCRIPT_NAME}

SYNOPSYS
        ${SCRIPT_NAME} [OPTIONS]

DESCRIPTION
        Neatly unpacks RPMs in a new directory for viewing

OPTIONS    
        -?|-h|--help
             Display this help and exit
    
        -v|--verbose
             Explain what is happening

EXAMPLE
        ${SCRIPT_NAME} test.rpm
        ${SCRIPT_NAME} test1.rpm test2.rpm test3.rpm
        ${SCRIPT_NAME} *.rpm

USAGE
}

################################################################################
# LOCAL FUNCTION: dependency_check()
# PURPOSE: check if command depemndency exists
# ARGUMENTS: command
dependency_check () {
    [[ $(command -v "${1}") ]] || { echo "${1} not installed"; exit 1; }
}

################################################################################
# LOCAL FUNCTION: unpack_rpm()
# PURPOSE: Unpack rpm contents in new directory
# ARGUMENTS: rpm

unpack_rpm () {
    local topdir="$(pwd)"
    local targetdir="${1}_unpacked"

    mkdir "${targetdir}" || { [[ "${VERBOSE}" == 1 ]] && echo "Skipping ${1}..." ; return 1 ;}
    mv "${1}" "${targetdir}" || exit 1
    cd "${targetdir}" || exit 1
    if [[ "${VERBOSE}" == 1 ]] ; then
        echo "Unpacking ${1}"
        rpm2cpio "${1}" | cpio -idmv
    else
        rpm2cpio "${1}" | cpio -idmv --quiet > /dev/null 2>&1
    fi
    mv "${1}" "${topdir}" || exit 1
    cd "${topdir}" || exit 1
}
###################################################
# MAIN PROGRAM

# Check Dependencies
for cmd in "${DEPENDENCIES[@]}"
do
    dependency_check "${cmd}"
done

# Parse the command line arguments:
while [[ "${1}" == -* ]] || [[ "${1}" == *.rpm ]]; do
    case "${1}" in
      -h|--help|-\?) usage; exit 0;;
      -v|--VERBOSE) VERBOSE=1; shift;;
      --) shift; break;;
      -*) echo "ERROR: invalid option: $1" 1>&2; usage; exit 1;;
      *.rpm) RPM_LIST+=( "${1}" ); shift;;
    esac
done

# Unpack RPMs
[[ "${VERBOSE}" == 1 ]] && echo "Unpacking all RPMs in current directory..."
for rpm in "${RPM_LIST[@]}"
do
    unpack_rpm "${rpm}"
done
[[ "${VERBOSE}" == 1 ]] && echo "All RPMs unpacked"
