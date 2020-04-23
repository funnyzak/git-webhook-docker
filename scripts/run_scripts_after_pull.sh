#!/bin/bash

if [ -n "$(ls -A /custom_scripts/after_pull/* 2>/dev/null)" ]; then
    for file in /custom_scripts/after_pull/*; do
        "$file"
    done
else 
    echo "no after_pull shell. skip."
fi
