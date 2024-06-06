#FROM node:20.10.0-alpine3.18
FROM ubuntu:22.04
USER root
RUN apt-get update
RUN apt-get -y install curl gnupg

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash
RUN apt-get install --yes nodejs
RUN node -v
RUN npm -v
RUN npm i -g nodemon
RUN nodemon -v

RUN apt-get install -y libappindicator1 fonts-liberation wget software-properties-common libasound2 libatk-bridge2.0-0 libatspi2.0-0 libdrm2 libgbm1 libgtk-4-1 libnspr4 libnss3 libu2f-udev libvulkan1 libxkbcommon0 xdg-utils
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome*.deb

RUN mkdir /.npm
RUN chown -R 1000:1000 "/.npm"
RUN mkdir /tmp-marp
RUN chown -R 1000:1000 "/tmp-marp"
RUN export TMPDIR=/tmp-marp