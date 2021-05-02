FROM golang:1.16-alpine as builder

WORKDIR /go/src/app
COPY . .

RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-s -w' -o /go/bin/ping main.go

FROM scratch
COPY --from=builder /go/bin/ping /ping

EXPOSE 8080

CMD ["/ping"]
