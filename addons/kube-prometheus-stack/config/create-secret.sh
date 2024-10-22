#!/bin/bash

SLACK_API_URL=https://slack.com/api/chat.postMessage
SLACK_BOT_TOKEN=$2
k create secret generic slack-bot-info --from-literal=token=$SLACK_BOT_TOKEN --from-literal=apiurl=$SLACK_API_URL -n monitoring