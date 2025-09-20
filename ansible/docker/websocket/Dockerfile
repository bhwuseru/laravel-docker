FROM node:23-slim

ARG PROJECT_NAME
ARG USER
ARG PASSWORD

ENV PROJECT_NAME=${PROJECT_NAME}
ENV USER=${USER}
ENV PASSWORD=${PASSWORD}
ENV TZ=Asia/Tokyo

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash git curl tzdata && \
  rm -rf /var/lib/apt/lists/*

RUN npm install -g pm2

WORKDIR /var/www/html

# COPY package*.json ./
# RUN npm install

COPY . .

# RUN npm run build

# EXPOSE 3001

# CMD ["npm", "start"]