FROM alpine:3.5

RUN apk update && apk add ruby ruby-json ruby-dev ca-certificates curl libcap libffi-dev build-base && \
rm -rf /var/cache/apk/*

RUN gem install --no-document sys-proctable httparty

ADD file-checker.rb /
ADD process-checker.rb /
ADD kubelet-checker.rb /
ADD api-server-checker.rb /
ADD service-token-checker.rb /
ADD amicontained.rb /

RUN chmod +x /amicontained.rb