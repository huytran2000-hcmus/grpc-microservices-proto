#!/bin/bash

SERVICE_NAME=$1
RELEASE_VERSION=$2
USER_NAME=$3
EMAIL=$4

git config user.name "$USER_NAME"
git config user.email "$EMAIL"
git fetch --all && git checkout main

PB_REL="https://github.com/protocolbuffers/protobuf/releases"
curl -LO $PB_REL/download/v25.0/protoc-25.0-linux-x86_64.zip
sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
unzip protoc-25.0-linux-x86_64.zip -d $HOME/.local
rm protoc-25.0-linux-x86_64.zip
chmod 755 $HOME/.local/bin/protoc
export PATH="$PATH:$HOME/.local/bin"

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
mkdir -p golang/${SERVICE_NAME}
protoc --go_out=./golang --go_opt=paths=source_relative \
  --go-grpc_out=./golang --go-grpc_opt=paths=source_relative \
 ./${SERVICE_NAME}/*.proto

cd golang/${SERVICE_NAME}
go mod init \
  github.com/huytran2000-hcmus/grpc-microservices-proto/golang/${SERVICE_NAME} || true
go mod tidy

cd ../../
git add . && git commit -am "proto update" || true
git push origin HEAD:main
git tag -fa golang/${SERVICE_NAME}/${RELEASE_VERSION} \
  -m "golang/${SERVICE_NAME}/${RELEASE_VERSION}" 
git push origin refs/tags/golang/${SERVICE_NAME}/${RELEASE_VERSION}
