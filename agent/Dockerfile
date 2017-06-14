FROM alpine:3.5

RUN apk update && apk add ruby ruby-json ca-certificates && \
rm -rf /var/cache/apk/*

RUN gem install --no-document sys-proctable httparty

ADD file-checker.rb /
ADD process-checker.rb /
ADD kubelet-checker.rb /
ADD api-server-checker.rb /
