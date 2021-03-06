#!/bin/bash

source /app/scripts/utils.sh;

mkdir -p -m 600 /root/.ssh
mkdir -p -m 700 /app/code

echo "Disable Strict Host checking for non interactive git clones"
rm -f /root/.ssh/config
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

echo "Add SSH key Permission 600"
chmod 600 /root/.ssh/id_rsa

echo "Setup git config"
if [ ! -z "$GIT_EMAIL" ]; then
 git config --global user.email "$GIT_EMAIL"
fi
if [ ! -z "$GIT_NAME" ]; then
 git config --global user.name "$GIT_NAME"
 git config --global push.default simple
fi


echo -e "git cloneing. Dont pull code down if the /app/code/.git folder exists"
if [ ! -d "/app/code/.git" ];then
  # Pull down code form git for our site!
  if [ ! -z "$GIT_REPO" ]; then
    rm /app/code/*
    if [ ! -z "$GIT_BRANCH" ]; then
      git clone  --recursive -b $GIT_BRANCH $GIT_REPO /app/code/
      cd /app/code && git checkout $GIT_BRANCH
      git reset --hard origin/$GIT_BRANCH
    else
      git clone --recursive $GIT_REPO /app/code/
    fi
    chown -Rf root:root /app/code/*
  else
    # if git repo not defined, pull from default repo:
    git clone  --recursive -b production git@github.com:vuejs/vuepress.git /app/code/
    # remove git files
    rm -rf /app/code/.git
  fi
fi

echo -e "add scripts permission"
chmod +x -R /custom_scripts
chmod +x -R /app/hook

notify_all "StartUp"

# Run any commands passed by env
if [ -n "$STARTUP_COMMANDS" ]; then
  echo -e "on startup command do: ${STARTUP_COMMANDS}" 
  (eval "$STARTUP_COMMANDS") || (echo -e "Start Up failed. Aborting;"; notify_error ; exit 1)
else
    echo -e "no startup command. skiped."
fi

echo -e "on startup shell do..." 

# Custom scripts
source /usr/bin/run_scripts_on_startup.sh

# run hook
source /app/hook/hook.sh &


# change hook match setting
HOOK_CONF=$(cat /app/hook/hooks.json | sed -e "s/\${branch}/${GIT_BRANCH}/" | sed -e "s/\${token}/${HOOK_TOKEN}/")

echo -e $HOOK_CONF >/app/hook/githooks.json

echo -e "Hook branch> ${GIT_BRANCH}. hook token: ${HOOK_TOKEN}"

if [ -n "$USE_HOOK" ]; then
  echo -e "start hook..."
  /go/bin/webhook -hooks /app/hook/githooks.json -verbose
else
  echo -e "no set USE_HOOK. will run in 23h."
  while sleep 23h; do sh /app/hook/hook.sh; done
fi

exec "$@"