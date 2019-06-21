FROM nginx:latest

LABEL maintainer="ow.diehl@gmail.com"

COPY _site /usr/share/nginx/html

