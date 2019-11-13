NAME  = hackernews

PROTOC_I = creack/grpc:go1.13-protobuf3.9.0-grpc1.24.0-protocgengo1.3.2
PROTOC   = docker run --rm --user $(shell id -u):$(shell id -g) -v ${PWD}:${PWD} -w ${PWD} ${PROTOC_I}
PROTOCTS = ${PROTOC} --plugin=protoc-gen-ts=./app/node_modules/.bin/protoc-gen-ts

PROTOS = server/proto/${NAME}.pb.go \
         app/src/proto/${NAME}_pb.d.ts \
         app/src/proto/${NAME}_pb.js \
         app/src/proto/${NAME}_pb_service.ts

.DEFAULT_GOAL = build

.PHONY: build clean

server/proto/${NAME}.pb.go: proto/${NAME}.proto
	@mkdir -p $(dir $@)
	${PROTOC} --go_out=plugins=grpc:./server $<

app/src/proto/${NAME}_pb_service.ts: proto/${NAME}.proto
	@mkdir -p $(dir $@)
	${PROTOCTS} --ts_out=service=true:./app/src $<

app/src/proto/${NAME}_pb.d.ts: app/src/proto/${NAME}_pb_service.ts
	@true

app/src/proto/${NAME}_pb.js: proto/${NAME}.proto
	@mkdir -p $(dir $@)
	${PROTOCTS} --js_out=import_style=commonjs,binary:./app/src $<

build: ${PROTOS}

clean:
	@rm -f ${PROTOS}
