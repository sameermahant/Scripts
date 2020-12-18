#!/usr/bin/bash

# Performance Monitor Script
#
# This script will capture the performance of given program using OS specific tools and stores it in file.
# On Linux OS it will use "top" command to capture performance parameters.
# On Solaris OS it will use "prstat" command to capture performance parameters.
#
# Author : Sameer Mahant
#

# SCRIPT CONSTANTS
PROCESS_NAME=<your_process_name>
WAIT_SEC=5

# OS DEPENDENT CONSTANTS
OS=""

#
# This function will set script variables depending on operating system
# If the OS is not as per required it will exit the script
#
DetectOSAndSetScriptVariables() {

    OSNAME=$(uname);
    echo "Operating System:" $(uname -a)
    echo ""
    case $OSNAME in
        Linux )
            OS="linux"
            ;;
        SunOS )
            OS="solaris"
            ;;
        * )
            echo "Unknown Operating System." 1>&2
            echo "Bye." 1>&2
            exit 1
            ;;
    esac
}

MonitorPerformanceOnLinux() {

    # Get the PID from process name
    pid=$(pgrep $PROCESS_NAME | tail -n 1)

    if [ -z "$pid" -o "$pid" == " " ]; then
        echo "Given process is not running."
        exit;
    fi
    curr_time=$(date +"%T")
    outfile=memory_profile_${pid}_$curr_time.log

    echo "Time PID CPU VIRT RES SHR MEM" >> $outfile

    while ! [ -z "$pid" -o "$pid" == " " ]
    do
        curr_time=$(date +"%T")
        echo -n $curr_time "" | tee -a $outfile
        COLUMNS=1024 top -n 1 -b p $pid | grep $pid | awk '{ print $1, $9, $5, $6, $7, $10 }' | tee -a $outfile
        sleep $WAIT_SEC;

        curr_pid=$(pgrep $PROCESS_NAME | tail -n 1)

        if [ -z "$curr_pid" -o "$curr_pid" == " " ]; then
            echo "Process is terminated."
            exit 0;
        fi

        if [ "$curr_pid" -ne "$pid" ]; then
            break;
        fi
    done
}

MonitorPerformanceOnSolaris() {

    # Get the PID from process name
    pid=$(pgrep $PROCESS_NAME | gtail -n 1)

    if [ -z "$pid" -o "$pid" == " " ]; then
        echo "Given process is not running."
        exit;
    fi
    curr_time=$(date +"%T")
    outfile=memory_profile_${pid}_$curr_time.log

    echo "Time PID CPU RSS SIZE" >> $outfile

    while ! [ -z "$pid" -o "$pid" == " " ]
    do
        curr_time=$(date +"%T")
        printf $curr_time | tee -a $outfile
        prstat -p $pid 1 1 | grep $pid | awk '{ print " " $1, $9, $4, $3 }' | tee -a $outfile
        sleep $WAIT_SEC;

        curr_pid=$(pgrep $PROCESS_NAME | gtail -n 1)

        if [ -z "$curr_pid" -o "$curr_pid" == " " ]; then
            echo "Process is terminated."
            exit 0;
        fi

        if [ "$curr_pid" -ne "$pid" ]; then
            break;
        fi
    done
}

#
# This function is the starting point of script
# It invokes other functions as required
#
main() {
    DetectOSAndSetScriptVariables

    if [ "$OS" == "linux" ]; then
        echo "Monitoring on Linux"
        MonitorPerformanceOnLinux
    elif [ "$OS" == "solaris" ]; then
        echo "Monitoring on Solaris"
        MonitorPerformanceOnSolaris
    fi
}

# call the main function
main
