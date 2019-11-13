NAME  = hackernews

PROTOC_BASE_I = creack/grpc:go1.13-protobuf3.9.0-grpc1.24.0-protocgengo1.3.2
GO_BASE_I = golang:1.13
NODE_BASE_I = mode:10

PROTOC_I = ${NAME}_protoc

PROTOC   = docker run --rm --user $(shell id -u):$(shell id -g) -v ${PWD}:${PWD} -w ${PWD} ${PROTOC_I}
PROTOCTS = ${PROTOC} --plugin=protoc-gen-ts=/usr/local/bin/protoc-gen-ts

GO_PROTOS = server/proto/${NAME}.pb.go client/proto/${NAME}.pb.go
JS_PROTOS = app/src/proto/${NAME}_pb.js \
            app/src/proto/${NAME}_pb.d.ts \
            app/src/proto/${NAME}_pb_service.js \
            app/src/proto/${NAME}_pb_service.d.ts
PROTOS = ${GO_PROTOS} ${JS_PROTOS}

.DEFAULT_GOAL = build

.PHONY: start build clean

PROTO_SRCS = proto/${NAME}.proto

.INTERMEDIATE: .protoc_i
.protoc_i: proto/Dockerfile
	docker build -t ${PROTOC_I} -f $< $(dir $<)
	@touch $@

server/proto/${NAME}.pb.go: proto/${NAME}.proto .protoc_i
	@mkdir -p $(dir $@)
	${PROTOC} --go_out=plugins=grpc:./server $<

client/proto/${NAME}.pb.go: server/proto/${NAME}.pb.go
	@mkdir -p $(dir $@)
	cp $< $@

app/src/proto/${NAME}_pb_service.js: proto/${NAME}.proto .protoc_i
	@mkdir -p $(dir $@)
	${PROTOCTS} --ts_out=service=grpc-web:./app/src $<

app/src/proto/${NAME}_pb_service.d.ts: app/src/proto/${NAME}_pb_service.js
	@true

app/src/proto/${NAME}_pb.js: proto/${NAME}.proto .protoc_i
	@mkdir -p $(dir $@)
	${PROTOCTS} --js_out=import_style=commonjs,binary:./app/src $<

app/src/proto/${NAME}_pb.d.ts: app/src/proto/${NAME}_pb_service.js
	@true

SERVER_SRCS = $(shell find ./server -name '*.go' -type f) server/proto/${NAME}.pb.go
.server_i: client/Dockerfile ${SERVER_SRCS}
	docker-compose build server
	@touch $@

CLIENT_SRCS = $(shell find ./client -name '*.go' -type f) client/proto/${NAME}.pb.go
.client_i: client/Dockerfile ${CLIENTS_SRCS}
	docker-compose build client
	@touch $@

APP_SRCS = $(shell find ./app -type f) ${JS_PROTOS}
.app_i: app/Dockerfile ${APP_SRCS}
	docker-compose build app
	@touch $@

build: ${PROTOS} .server_i .client_i .app_i

start: build .app_c .server_c

.%_c: .%_i
	docker-compose up -d $*
	@touch $@

log-%: .%_c
	docker-compose logs -t -f $*

log-server log-client log-app:

clean:
	@rm -f ${PROTOS}
	@rm -f  .client_i .server_i .app_i .protoc_i
	@rm -f  .client_c .server_c .app_c
	@(docker-compose kill -s 9 && docker-compose rm -f -v) > /dev/null 2> /dev/null || true
