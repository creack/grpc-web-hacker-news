ARG PROTOC_BASE_I=creack/grpc:go1.13-protobuf3.9.0-grpc1.24.0-protocgengo1.3.2
FROM ${PROTOC_BASE_I}

RUN apt-get update && apt-get install -y nodejs npm

RUN npm install --global ts-protoc-gen

RUN echo '{}' > package.json && npm install ts-protoc-gen && cat package.json
RUN npm install typescript && cat package.json
