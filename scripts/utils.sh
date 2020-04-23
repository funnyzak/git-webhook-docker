#!/bin/bash
# author:funnyzak
# email:silenceace@gmail.com

# send notification to url 
function notify_url_single(){
    ACTION_NAME=$1
    NOTIFY_URL=$2

    if [ "$1" == "AfterPackage" ]; then
         elasped_lable="\"_elasped\": \"$(elasped_package_time_label)\","
         elasped_lable2="&_elasped=$(elasped_package_time_label)"
    fi

    echo "$APP_NAME $ACTION_NAME. 【$NOTIFY_URL】Web Notify Notification Sending..."

    # current timestamp
    CURRENT_TS=$(date +%s)
    curl "$NOTIFY_URL" \
        -H "Content-Type: application/json" \
        -d "{
                \"_time\": \"$CURRENT_TS\",
                \"_name\": \"$APP_NAME\",
                ${elasped_lable}
                \"_action\": \"$ACTION_NAME\"
        }"
    curl -G "$NOTIFY_URL" \
        -d "_time=$CURRENT_TS$elasped_lable2&_name=$APP_NAME&_action=$ACTION_NAME"

    echo "$APP_NAME $ACTION_NAME. 【$NOTIFY_URL】Web Notify Notification Sended."
}

# send notification to dingtalk
function dingtalk_notify_single() {
    ACTION_NAME=`parse_action_label "$1"`
    TOKEN=$2

    if [ "$1" == "AfterPackage" ]; then
         elasped_lable="Elasped Time: `elasped_package_time_label`"
    fi
    
    echo "$APP_NAME $ACTION_NAME. DingTalk Notification Sending..."
    curl "https://oapi.dingtalk.com/robot/send?access_token=${TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{
        "msgtype": "markdown",
        "markdown": {
            "title":"'"$APP_NAME"' '"$ACTION_NAME"'.",
            "text": "#### 【'"$APP_NAME"'】 '"$ACTION_NAME"'. \n> Branch：'"$(parse_git_branch)"' \n\n> Commit Msg：'"$(parse_git_message)"'\n\n> Commit ID: '"$(parse_git_hash)"'\n\n'"${elasped_lable}"'"
        },
            "at": {
            "isAtAll": true
            }
        }'

    echo "$APP_NAME $ACTION_NAME. DingTalk Notification Sended."
}

# send notification to jishida
function jishida_notify_single() {
    ACTION_NAME=`parse_action_label "$1"`
    TOKEN=$2

    if [ "$1" == "AfterPackage" ]; then
         elasped_lable="Elasped Time: `elasped_package_time_label`"
    fi
    
    echo "$APP_NAME $ACTION_NAME. JiShiDa Notification Sending..."
    curl --location --request POST "http://push.ijingniu.cn/send" \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data-urlencode "key=${TOKEN}" \
        --data-urlencode "head=${APP_NAME}${ACTION_NAME}." \
        --data-urlencode "body=${ACTION_NAME}, Branch：$(parse_git_branch);  Commit Msg：$(parse_git_message);  Commit ID: $(parse_git_hash);  ${elasped_lable}."

    echo "$APP_NAME $ACTION_NAME. JiShiDa Notification Sended."
}

function ifttt_single() {
    ACTION_NAME=`parse_action_label "$1"`
    NOTIFY_URL=$2

    if [ "$1" == "AfterPackage" ]; then
         elasped_lable=`elasped_package_time_label`
    fi
    
     echo "$APP_NAME $ACTION_NAME. 【$NOTIFY_URL】IFTTT Notify Notification Sended."
    curl -X POST -H "Content-Type: application/json" -d "{\"value1\":\"$APP_NAME\",\"value2\":\"$ACTION_NAME\",\"value3\":\"${elasped_lable}\"}" "$NOTIFY_URL"
     echo "$APP_NAME $ACTION_NAME. 【$NOTIFY_URL】IFTTT Notify Notification Sended."
}

function parse_action_label(){
    if [ -n "$NOTIFY_ACTION_LABEL" ]; then
        label_arr=(${NOTIFY_ACTION_LABEL//|/ })
        action_idx=`parse_action_index "$1"`
        if [ $action_idx == -1 ]; then
            echo "$1"
        else
            echo ${label_arr[action_idx]} 
        fi
    else
        echo "$1"
    fi
}

ACTION_ARRAY=(StartUp BeforePull AfterPull AfterPackage)
function parse_action_index(){
    for i in "${!ACTION_ARRAY[@]}"; do
        if [ "${ACTION_ARRAY[$i]}" == "${1}" ]; then
            idx="${i}";
        fi
    done
    if [ -n "$idx" ]; then
        echo $idx
    else
        echo -1
    fi
}

# $3 url or token list
# $1 func name
# $2 action
function notify_run(){
    if [ -n "$3" ]; then
        for item in ${3//|/ }
        do
            eval "$1 \"$2\" \"$item\""
        done
    fi
}

# notify all notify service
function notify_all(){
    if [ ! -n "$NOTIFY_ACTION_LIST" ]; then
        NOTIFY_ACTION_LIST="BeforePull|AfterPackage"
    fi
    action_str_idx=`awk "BEGIN{ print index(\"$NOTIFY_ACTION_LIST\",\"$1\") }"`

    if [ $action_str_idx -gt 0 -o $1 == "Error" ]; then
        notify_run "notify_url_single" "$1" "$NOTIFY_URL_LIST"
        notify_run "dingtalk_notify_single" "$1" "$DINGTALK_TOKEN_LIST"
        notify_run "jishida_notify_single" "$1" "$JISHIDA_TOKEN_LIST"
        notify_run "ifttt_single" "$1" "$IFTTT_HOOK_URL_LIST"
    fi
}

function notify_error(){
    ERROR_MSG="Package Error, Please Check Runtime Logs"
    notify_run "notify_url_single" "$ERROR_MSG" "$NOTIFY_URL_LIST"
    notify_run "dingtalk_notify_single" "$ERROR_MSG" "$DINGTALK_TOKEN_LIST"
    notify_run "jishida_notify_single" "$ERROR_MSG" "$JISHIDA_TOKEN_LIST"
    notify_run "ifttt_single" "$ERROR_MSG" "$IFTTT_HOOK_URL_LIST"
}

# record end time as long as "$1" is present
# record start:elasped_package_time 
# record end: elasped_package_time "end"
function elasped_package_time(){
    if [ -n "$1" ]; then
        # 计算部署耗时
        PULL_START_TS=`cat /tmp/PULL_START_TS`
        ELAPSED_TIME=`expr $(date +%s) - $PULL_START_TS`
        ELAPSED_TIME_M=`expr $ELAPSED_TIME / 60`
        ELAPSED_TIME_S=`expr $ELAPSED_TIME % 60`
        ELAPSED_TIME_LABEL="${ELAPSED_TIME_M}分${ELAPSED_TIME_S}秒"

        if [ $ELAPSED_TIME -ge 60 ]
        then
            ELAPSED_TIME_LABEL="${ELAPSED_TIME_M}分${ELAPSED_TIME_S}秒"
        else
            ELAPSED_TIME_LABEL="${ELAPSED_TIME_S}秒"
        fi
        # 耗时临时缓存
        echo $ELAPSED_TIME > /tmp/ELAPSED_TIME
        echo $ELAPSED_TIME_LABEL > /tmp/ELAPSED_TIME_LABEL
    else
        echo $(date +%s) > /tmp/PULL_START_TS
    fi
}

function elasped_package_time_label(){
    echo `cat /tmp/ELAPSED_TIME_LABEL`
}


# checks if branch has something pending
parse_git_dirty() {
    git diff --quiet --ignore-submodules HEAD 2>/dev/null
    [ $? -eq 1 ] && echo "*"
}

# gets the current git branch
parse_git_branch() {
    git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

# get last commit hash prepended with @ (i.e. @8a323d0)
parse_git_hash() {
    git rev-parse --short HEAD 2>/dev/null | sed "s/\(.*\)/@\1/"
}

# get last commit message
parse_git_message() {
    git show --pretty=format:%s -s HEAD 2>/dev/null
}