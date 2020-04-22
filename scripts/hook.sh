#!/bin/bash

set -e

cd /app/code

# git pull code before script run
if [ -n "$BEFORE_PULL_COMMANDS" ]; then
    echo "git pull code before command do: ${BEFORE_PULL_COMMANDS}" 
    $BEFORE_PULL_COMMANDS || (echo "git pull code before Command failed. Aborting!"; exit 1)
fi

echo "git pull code before shell do..." 
source /usr/bin/run_scripts_before_pull.sh


# git pull code
echo "git pull code ..." 
git pull
echo "git pull code end."


# git pull code after script run
if [ -n "$AFTER_PULL_COMMANDS" ]; then
    echo "git pull code after command do: ${AFTER_PULL_COMMANDS}" 
    $AFTER_PULL_COMMANDS || (echo "git pull code after Command failed. Aborting!"; exit 1)
fi

echo "git pull code after shell do..." 
source /usr/bin/run_scripts_after_pull.sh

