FROM alpine:3.5

RUN apk update && apk add ruby ruby-json && \
rm -rf /var/cache/apk/*

ADD file-checker.rb /

ENTRYPOINT ["/file-checker.rb"]
