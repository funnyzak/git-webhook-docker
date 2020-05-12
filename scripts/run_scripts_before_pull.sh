#!/bin/bash

if [ -n "$(ls -A /custom_scripts/before_pull/* 2>/dev/null)" ]; then
    for file in /custom_scripts/before_pull/*; do
        "$file"
    done
else 
    echo -e "no before_pull shell. skip."
fi