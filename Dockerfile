ARG golang_image=public.ecr.aws/eks-distro-build-tooling/golang:1.25.7

FROM --platform=$BUILDPLATFORM $golang_image AS builder
WORKDIR $GOPATH/src/github.com/aws/amazon-eks-pod-identity-webhook
COPY . ./

# Build SENZA -w -s (rimuovono i simboli di debug) e CON -N -l
RUN GOPROXY=direct CGO_ENABLED=0 go build \
    -gcflags="all=-N -l" \
    -o /webhook -v .

# Installa Delve
RUN go install github.com/go-delve/delve/cmd/dlv@latest

FROM --platform=$TARGETPLATFORM $golang_image
COPY --from=builder /webhook /webhook
COPY --from=builder /go/bin/dlv /dlv

EXPOSE 2345

ENTRYPOINT ["/dlv"]
CMD ["--listen=:2345", "--headless=true", "--api-version=2", "--accept-multiclient", "exec", "/webhook"]