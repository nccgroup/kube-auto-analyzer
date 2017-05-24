FROM alpine:3.5

RUN apk update && apk add ruby ruby-dev g++ make && \
rm -rf /var/cache/apk/*

RUN mkdir /data

RUN gem install --no-document json kubeclient kube_auto_analyzer

WORKDIR /data

ENTRYPOINT ["kubeautoanalyzer"]