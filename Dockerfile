FROM golang:1.16-alpine as builder

WORKDIR /go/src/app
COPY . .

RUN go mod tidy
RUN arch="$(apk --print-arch)"; \
    case "$arch" in \
		'x86_64') \
			export GOARCH='amd64' GOOS='linux'; \
			;; \
		'armhf') \
			export GOARCH='arm' GOARM='6' GOOS='linux'; \
			;; \
		'armv7') \
			export GOARCH='arm' GOARM='7' GOOS='linux'; \
			;; \
		'aarch64') \
			export GOARCH='arm64' GOOS='linux'; \
			;; \
		'x86') \
			export GO386='softfloat' GOARCH='386' GOOS='linux'; \
			;; \
		'ppc64le') \
			export GOARCH='ppc64le' GOOS='linux'; \
			;; \
		's390x') \
			export GOARCH='s390x' GOOS='linux'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
    esac; \
    CGO_ENABLED=0 go build -a -ldflags '-s -w' -o /go/bin/ping main.go

FROM scratch
COPY --from=builder /go/bin/ping /ping

EXPOSE 8080

CMD ["/ping"]
