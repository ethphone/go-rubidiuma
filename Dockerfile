# Build Grbd in a stock Go builder container
FROM golang:1.12-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

ADD . /go-rubidiuma
RUN cd /go-rubidiuma && make grbd

# Pull Grbd into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-rubidiuma/build/bin/grbd /usr/local/bin/

EXPOSE 7764 7765 33460 33460/udp
ENTRYPOINT ["grbd"]
