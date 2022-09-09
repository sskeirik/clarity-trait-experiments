#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

$SCRIPT_DIR/run-tests.sh time 2>&1 | grep '^>>> ' | cut -c 5- | awk 'NR%2{printf "%s ",$0;next;}1'
