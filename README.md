# Git Webhook Docker

Pull your project git code into a data volume and trigger event via Webhook.

[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/git-webhook.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-webhook/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/git-webhook.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-webhook/)

This image is based on Alpine Linux image, which is a 439MB image.

Download size of this image is:

[![](https://images.microbadger.com/badges/image/funnyzak/git-webhook.svg)](http://microbadger.com/images/funnyzak/git-webhook)

[Docker hub image: funnyzak/git-webhook](https://hub.docker.com/r/funnyzak/git-webhook)

Docker Pull Command: `docker pull funnyzak/git-webhook`

Webhook Url: [http://hostname:9000/hooks/git-webhook?token=HOOK_TOKEN](#)

---

## Main Modules

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
* unzip 6.0
* tar 1.32
* wget 1.20.3
* curl 7.66
* rsync 3.1.3
* git 2.22
* bash 5.0.0
* webhook [Help](https://github.com/adnanh/webhook)

### Other Modules

* tzdata
* fc-config
* msttcorefonts
* gcc
* g++
* make
  
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
* **AFTER_PACKAGE_COMMANDS** : Optional. Add any commands that will be run after package. left blank, will not execute.

### Notify

* **NOTIFY_ACTION_LABEL**: Optional. notify action name define. default : `StartUp|BeforePull|AfterPull|AfterPackage`
* **NOTIFY_ACTION_LIST**: Optional. notify action list. included events will be notified. default : `BeforePull|AfterPackage`
* **NOTIFY_URL_LIST** : Optional. Notify link array , each separated by **|**
* **TELEGRAM_BOT_TOKEN**: Optional. telegram Bot Token-chatid setting. eg: **token###chatid|token2###chatid2**. each separated by **|** [Official Site](https://core.telegram.org/api).
* **IFTTT_HOOK_URL_LIST** : Optional. ifttt webhook url array , each separated by **|** [Official Site](https://ifttt.com/maker_webhooks).
* **DINGTALK_TOKEN_LIST**: Optional. DingTalk Bot TokenList, each separated by **|** [Official Site](http://www.dingtalk.com).
* **JISHIDA_TOKEN_LIST**: Optional. JiShiDa TokenList, each separated by **|**. [Official Site](http://push.ijingniu.cn/admin/index/).
* **APP_NAME** : Optional. When setting notify, it is best to set.

---

## Volume

* **/app/code** : git source code dir. docker work dir.
* **/root/.ssh** :  ssh key folder.
* **/custom_scripts/on_startup** :  which the scripts are executed at startup, traversing all the scripts and executing them sequentially
* **/custom_scripts/before_pull** :  which the scripts are executed at before pull
* **/custom_scripts/after_pull** :  which the scripts are executed at after pull
* **/custom_scripts/after_package** :  which the scripts are executed at after package.

## ssh-keygen

`ssh-keygen -t rsa -b 4096 -C "youremail@gmail.com" -N "" -f ./id_rsa`

---

## SendMessage

You can use notifications by call "/app/scripts/utils.sh" in the execution script.

```bash
source /app/scripts/utils.sh;

notify_all "hello world"
```

---

## Display Package Elapsed Time

show package elapsed second.

```sh
docker exec servername cat /tmp/ELAPSED_TIME
```

show package elapsed time label.

```sh
docker exec servername cat /tmp/ELAPSED_TIME_LABEL
```

show git commit hash that currently deployed successfully.
```sh
docker exec servername cat /tmp/CURRENT_GIT_COMMIT_ID
```

___

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
      - BEFORE_PULL_COMMANDS=echo "AFTER_PULL_COMMANDS”
      - APP_NAME=myapp
      - NOTIFY_ACTION_LABEL=已启动|源码拉取中..|源码已拉取最新,开始打包..|部署已完成
      - NOTIFY_ACTION_LIST=StartUp|BeforePull|AfterPull|AfterPackage
      - TELEGRAM_BOT_TOKEN=123456789:SDFW33-CbovPM2TeHFCiPUDTLy1uYmN04I###9865678987
      - DINGTALK_TOKEN_LIST=dingtoken_one|dingtoken_two
      - JISHIDA_TOKEN_LIST=jishida_token
    restart: on-failure
    ports:
      - 1001:9000
    volumes:
      - ./custom_scripts:/custom_scripts
      - ./code:/app/code
      - ./ssh:/root/.ssh

 ```
