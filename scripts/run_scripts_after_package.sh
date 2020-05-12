#!/bin/bash

if [ -n "$(ls -A /custom_scripts/after_package/* 2>/dev/null)" ]; then
    for file in /custom_scripts/after_package/*; do
        "$file"
    done
else 
    echo -e "no after_package shell. skip."
fi
