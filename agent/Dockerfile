FROM alpine:3.5

RUN apk update && apk add ruby ruby-json ca-certificates curl libcap && \
rm -rf /var/cache/apk/*

RUN gem install --no-document sys-proctable httparty

ADD file-checker.rb /
ADD process-checker.rb /
ADD kubelet-checker.rb /
ADD api-server-checker.rb /
ADD service-token-checker.rb /

#Get AmIcontained
RUN curl -OL https://github.com/jessfraz/amicontained/releases/download/v0.0.8/amicontained-linux-amd64 && \
cp amicontained-linux-amd64 /usr/local/bin/amicontained && chmod +x /usr/local/bin/amicontained