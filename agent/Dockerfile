FROM alpine:3.5

RUN apk update && apk add ruby ruby-json && \
rm -rf /var/cache/apk/*

RUN gem install --no-document sys-proctable

ADD file-checker.rb /
ADD process-checker.rb /
