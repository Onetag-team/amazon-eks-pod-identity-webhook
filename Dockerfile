ARG golang_image=public.ecr.aws/eks-distro-build-tooling/golang:1.25.7

FROM --platform=$BUILDPLATFORM $golang_image AS builder
WORKDIR $GOPATH/src/github.com/aws/amazon-eks-pod-identity-webhook
COPY . ./

RUN GOPROXY=direct CGO_ENABLED=0 go build \
    -gcflags="all=-N -l" \
    -o /webhook -v .

RUN go install github.com/go-delve/delve/cmd/dlv@latest

FROM debian:bookworm-slim
COPY --from=builder /webhook /webhook
COPY --from=builder /go/bin/dlv /dlv

EXPOSE 2345

ENTRYPOINT ["/dlv", "--listen=:2345", "--headless=true", "--api-version=2", "--accept-multiclient", "exec", "/webhook"]