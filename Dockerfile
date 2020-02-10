FROM alpine:3.11 as gatherer

RUN apk add git curl unzip wget bash openjdk9-jre-headless

WORKDIR /

RUN mkdir /docroot

RUN curl -O -L https://github.com/alssndro/trianglify-background-generator/archive/master.zip
RUN unzip -d /docroot/trianglify-background-generator-master master.zip
RUN rm -f master.zip

RUN curl -L -O https://github.com/tiborsaas/unique-gradient-generator/archive/gh-pages.zip
RUN unzip gh-pages.zip
RUN rm -f gh-pages.zip
RUN mv unique-gradient-generator-gh-pages/ /docroot/unique-gradient-generator

RUN wget -kr -np -nH https://tools.superdevresources.com/gradient-generator/
RUN mv gradient-generator/ /docroot/gradient-generator

WORKDIR /docroot
RUN git clone https://github.com/lewish/asciiflow2.git
WORKDIR asciiflow2
RUN ./compile.sh
RUN rm -rf .git
WORKDIR /



FROM golang:alpine as packager

RUN apk add git
RUN go get github.com/rakyll/statik

WORKDIR /

COPY --from=gatherer /docroot /docroot
COPY docroot/* /docroot/
RUN statik -src=/docroot
RUN ls -al

COPY main.go /main.go

RUN mkdir /build
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /build/friends .



FROM scratch

LABEL maintainer="arne@hilmann.de"

COPY --from=packager /build/friends /friends
EXPOSE 8081
CMD ["/friends"]
