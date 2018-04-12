FROM alpine:3.7

RUN apk add --no-cache openssh-keygen

ADD blah.txt /usr/src/blah.txt

RUN apk add --no-cache openssh-client
