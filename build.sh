#!/bin/bash

USERNAME="3mdeb"
IMAGE="slack-cleaner-docker"

wget https://raw.githubusercontent.com/3mdeb/slack-downloader/master/slack-downloader.py
docker build -t $USERNAME/$IMAGE:latest .
