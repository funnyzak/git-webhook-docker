# Git Webhook Docker

Pull your project git code into a data volume and trigger event via Webhook.

[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/git-webhook.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-webhook/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/git-webhook.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-webhook/)

This image is based on Alpine Linux image, which is a 420MB image.

Download size of this image is:

[![](https://images.microbadger.com/badges/image/funnyzak/git-webhook.svg)](http://microbadger.com/images/funnyzak/git-webhook)

[Docker hub image: funnyzak/git-webhook](https://hub.docker.com/r/funnyzak/git-webhook)

Docker Pull Command: `docker pull funnyzak/git-webhook`

Webhook Url: [http://hostname:9000/hooks/git-webhook?token=HOOK_TOKEN](#)

---

## Environment

* java 1.8
* go 1.12.12
* python 3.9
* nodejs 10.19.0
* npm 10.19.0
* yarn 1.16.0
* mvn 3.39
* nginx 1.16.1
* openssh 8.1
* zip 3.0
* tar 1.32
* wget 1.20.3
* rsync 3.13
* git 2.22
* bash
* webhook [Help](https://github.com/adnanh/webhook)
  
---
  
## Available Parameters

The following flags are a list of all the currently supported options that can be changed by passing in the variables to docker with the -e flag.

* **USE_HOOK** : The web hook is enabled as long as this is present.
* **HOOK_TOKEN** : Custom hook security tokens, strings.
* **GIT_REPO** : If it is a private repository, and is ssh link, set the private key file with the file name ***id_rsa*** must be set. If you use https link, you can also set this format link type: ***https://GIT_TOKEN@GIT_REPO***.
* **GIT_BRANCH** : Select a branch for clone and auto hook match.
* **GIT_EMAIL** : Set your email for git (required for git to work).
* **GIT_NAME** : Set your name for git (required for git to work).
* **STARTUP_COMMANDS** : Optional. Add any commands that will be run at the end of the start.sh script. left blank, will not execute.
* **AFTER_PULL_COMMANDS** : Optional. Add any commands that will be run after pull. left blank, will not execute.
* **BEFORE_PULL_COMMANDS** : Optional. Add any commands that will be run before pull. left blank, will not execute.
  
---

## Volume

* **/app/code** : git source code dir. docker work dir.
* **/root/.ssh** :  ssh key folder.
* **/custom_scripts/on_startup** :  which the scripts are executed at startup, traversing all the scripts and executing them sequentially
* **/custom_scripts/before_pull** :  which the scripts are executed at before pull
* **/custom_scripts/after_pull** :  which the scripts are executed at after pull

### ssh-keygen

`ssh-keygen -t rsa -b 4096 -C "youremail@gmail.com" -N "" -f ./id_rsa`

---

## Docker-Compose

 ```docker
version: '3'
services:
  hookserver:
    image: funnyzak/git-webhook
    privileged: true
    container_name: git-hook
    working_dir: /app/code
    logging:
      driver: 'json-file'
      options:
        max-size: '1g'
    tty: true
    environment:
      - TZ=Asia/Shanghai
      - LANG=C.UTF-8
      - USE_HOOK=1
      - HOOK_TOKEN=hello
      - GIT_REPO=https://github.com/vuejs/vuepress.git
      - GIT_BRANCH=master
      - GIT_EMAIL=youremail
      - GIT_NAME=yourname
      - STARTUP_COMMANDS=echo "STARTUP_COMMANDS helllo"
      - AFTER_PULL_COMMANDS=echo "AFTER_PULL_COMMANDS hello"
      - BEFORE_PULL_COMMANDS=echo "AFTER_PULL_COMMANDS hello"
    restart: on-failure
    ports:
      - 1001:9000
    volumes:
      - ./custom_scripts:/custom_scripts
      - ./code:/app/code
      - ./ssh:/root/.ssh

 ```