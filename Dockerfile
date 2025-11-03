FROM postgres:13.1-alpine as postgres

RUN apk add --no-cache build-base

WORKDIR /app
COPY . .
