#!/bin/bash

run_script() {
    bash "$1" 2>>"$ERROR_LOG_FILE" || {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $1" >>"$ERROR_LOG_FILE"
    }
}
