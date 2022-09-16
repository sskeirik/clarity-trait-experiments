#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

val=$($SCRIPT_DIR/run-tests.sh time 2>&1 | grep '^>>> ' | cut -c 5- | awk 'NR%2{printf "%s\t",$0;next;}1')
echo -e "time\tstatus\tname"
echo "$val"
