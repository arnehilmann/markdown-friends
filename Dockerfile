FROM alpine:3.11 as build-trianglify

WORKDIR /tmp
RUN apk add git curl unzip
RUN curl -O -L https://github.com/alssndro/trianglify-background-generator/archive/master.zip
RUN mkdir /docroot
RUN unzip -d /docroot/ master.zip



FROM alpine:3.11 as build-unique-gradient-generator

WORKDIR /tmp
RUN apk add curl unzip
RUN curl -L -O https://github.com/tiborsaas/unique-gradient-generator/archive/gh-pages.zip
RUN mkdir /docroot
RUN unzip -d /docroot gh-pages.zip
RUN mv /docroot/unique-gradient-generator-gh-pages/ /docroot/unique-gradient-generator



FROM alpine:3.11 as build-gradient-generator

WORKDIR /tmp
RUN apk add wget
RUN wget -kr -np -nH https://tools.superdevresources.com/gradient-generator/
RUN mkdir /docroot
RUN mv gradient-generator /docroot/



FROM alpine:3.11 as build-asciiflow2

WORKDIR /tmp
RUN apk add git bash openjdk9-jre-headless
RUN git clone https://github.com/lewish/asciiflow2.git
WORKDIR asciiflow2
RUN ./compile.sh
RUN rm -rf .git
RUN mkdir /docroot
WORKDIR /tmp
RUN mv asciiflow2 /docroot/



FROM alpine:3.11 as build-excalidraw

WORKDIR /tmp
RUN apk add git npm jq
RUN git clone https://github.com/excalidraw/excalidraw.git
WORKDIR excalidraw
RUN npm install
RUN npm audit fix
RUN jq '.homepage = "/excalidraw/"' < package.json > package.json.tmp
RUN mv package.json.tmp package.json
RUN npm run build
RUN mkdir /docroot
RUN mv build /docroot/excalidraw



FROM golang:alpine as packager

RUN apk add git
RUN go get github.com/rakyll/statik

WORKDIR /
COPY --from=build-trianglify /docroot /docroot
COPY --from=build-unique-gradient-generator /docroot /docroot
COPY --from=build-gradient-generator /docroot /docroot
COPY --from=build-asciiflow2 /docroot /docroot
COPY --from=build-excalidraw /docroot /docroot
RUN ls -al /docroot
COPY docroot/ /docroot/
RUN ls -al /docroot
RUN statik -src=/docroot

COPY main.go /main.go

RUN mkdir /build
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /build/friends .



FROM scratch

LABEL maintainer="arne@hilmann.de"

COPY --from=packager /build/friends /friends
EXPOSE 8081
CMD ["/friends"]
