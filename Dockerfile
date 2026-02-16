FROM golang:alpine3.23 AS builder

RUN apk add --no-cache npm wget make

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN make all

FROM alpine:3.23

RUN apk add --no-cache ca-certificates

WORKDIR /opt/galene
COPY --from=builder /src/galene .
COPY --from=builder /src/static ./static
COPY --from=builder /src/groups ./groups

VOLUME /opt/galene/data
VOLUME /opt/galene/groups
VOLUME /opt/galene/recordings

EXPOSE 8443

ENTRYPOINT ["./galene"]
