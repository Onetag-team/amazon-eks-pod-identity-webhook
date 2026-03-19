#!/usr/bin/env bash
set -euo pipefail

source hack/setup-go.sh

T=github.com/aws/amazon-eks-pod-identity-webhook
GOOS=$(go env GOOS)
go version
GOARCH=amd64
GOARCH=amd64 go build -mod=vendor -o build/gopath/bin/${GOARCH/amd64/amazon-eks-pod-identity-webhook} -ldflags='-s -w -buildid=""' $T
