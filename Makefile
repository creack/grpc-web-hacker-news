PROTOC = docker run --rm --user $(shell id -u):$(shell id -g) -e HOME -v ${HOME}:${HOME} -w ${PWD} -e GOPATH=${HOME}/go:/go creack/grpc:go1.13-protobuf3.9.0-grpc1.24.0-protocgengo1.3.2

JS_PROTOS = app/src/proto/hackernews_pb.d.ts app/src/proto/hackernews_pb.js app/src/proto/hackernews_pb_service.ts
GO_PROTOS = server/proto/hackernews.pb.go

.DEFAULT_GOAL = build

${GO_PROTOS}: proto/hackernews.proto
	@mkdir -p $(dir $@)
	${PROTOC} --go_out=plugins=grpc:./$(dir $@) $<

app/src/proto/hackernews_pb.d.ts: proto/hackernews.proto
	@mkdir -p $(dir $@)
	${PROTOC} --plugin=protoc-gen-ts=./app/node_modules/.bin/protoc-gen-ts --ts_out=service=true:./$(dir $@) $<

app/src/proto/hackernews_pb.js: proto/hackernews.proto
	@mkdir -p $(dir $@)
	${PROTOC} --plugin=protoc-gen-ts=./app/node_modules/.bin/protoc-gen-ts --js_out=import_style=commonjs:./$(dir $@) $<

app/src/proto/hackernews_pb_service.ts: proto/hackernews.proto
	@mkdir -p $(dir $@)
	${PROTOC} --plugin=protoc-gen-ts=./app/node_modules/.bin/protoc-gen-ts --js_out=import_style=binary:./$(dir $@) $<

.PHONY: build
build: ${GO_PROTOS} ${JS_PROTOS}

.PHONY: clean
clean:
	@rm -f ${GO_PROTOS} ${JS_PROTOS}
