#!/bin/bash

if [ -n "$(ls -A /custom_scripts/on_startup/* 2>/dev/null)" ]; then
    for file in /custom_scripts/on_startup/*; do
        "$file"
    done
else 
    echo "no on_startup shell. skip."
fi