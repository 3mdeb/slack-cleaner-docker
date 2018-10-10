#!/bin/bash

BEFORE_DATE="$1"

[ -z "$SLACK_TOKEN" ] && echo "SLACK_TOKEN not given" && exit 1
[ -z "$BACKUP_DIR" ] && echo "BACKUP_DIR not given" && exit 1
[ -z "$BEFORE_DATE" ] && echo "BEFORE_DATE not given" && exit 1

docker run --rm -it \
    -e SLACK_TOKEN="$SLACK_TOKEN" \
    -v $BACKUP_DIR:/slack/backup \
    3mdeb/slack-cleaner-docker $1
