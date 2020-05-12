#!/bin/bash

set -e

source /app/scripts/utils.sh;

echo -e "================================starting run hook script================================"

cd /app/code

notify_all "BeforePull"

# record pull start timestamp
elasped_package_time

# git pull code before script run
if [ -n "$BEFORE_PULL_COMMANDS" ]; then
    echo -e "git pull code before command do: ${BEFORE_PULL_COMMANDS}" 
    $BEFORE_PULL_COMMANDS || (echo -e "git pull code before Command failed. Aborting!"; exit 1)
else
    echo -e "no before pull command. skiped."
fi

echo -e "git pull code before shell do..." 
source /usr/bin/run_scripts_before_pull.sh


# git pull code
echo -e "git pull code ..." 
git pull
echo -e "git pull code end."


# record current git commit id
echo -e $(parse_git_hash) > /tmp/CURRENT_GIT_COMMIT_ID

# notify send
notify_all "AfterPull"


# git pull code after script run
if [ -n "$AFTER_PULL_COMMANDS" ]; then
    echo -e "git pull code after command do: ${AFTER_PULL_COMMANDS}" 
    $AFTER_PULL_COMMANDS || (echo -e "git pull code after Command failed. Aborting!"; exit 1)
else
    echo -e "no after pull command. skiped."
fi


echo -e "git pull code after shell do..." 
source /usr/bin/run_scripts_after_pull.sh

# after package command
if [ -n "$AFTER_PACKAGE_COMMANDS" ]; then
    echo -e "after package command do: ${AFTER_PACKAGE_COMMANDS}" 
    $AFTER_PACKAGE_COMMANDS || (echo -e "After Package Command failed. Aborting!"; notify_error; exit 1)
else
    echo -e "no after package command. skiped."
fi


echo -e "after package shell do..." 
source /usr/bin/run_scripts_after_package.sh

# calc package elasped time
elasped_package_time "end"


# after package notify
notify_all "AfterPackage"

echo -e "================================end run hook script================================" 
