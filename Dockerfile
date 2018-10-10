FROM python:2.7.15-slim-stretch

MAINTAINER "Maciej Pijanowski" <maciej.pijanowski@3mdeb.com>

COPY requirements.txt .

RUN useradd -ms /bin/bash cleaner && \
    usermod -aG sudo cleaner

RUN  pip install --no-cache-dir --upgrade pip && \
     pip install --no-cache-dir -r requirements.txt

RUN mkdir -p /slack/workdir/ /slack/backup/
COPY entrypoint.sh slack-downloader.py /slack/workdir/
WORKDIR /slack/workdir/

ENTRYPOINT ["/slack/workdir/entrypoint.sh"]
