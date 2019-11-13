FROM golang:1.13 AS builder

# Disabl CGO to enable static linking.
ENV CGO_ENABLED=0
# Precompile the stdlib without cgo.
RUN go install -a std

ENV GOBIN=/bin
RUN go get github.com/cespare/reflex

WORKDIR /app

# Precompile vendors.
ADD vendor/ /app/vendor
ADD go.sum go.mod /app/
RUN go build -i -v -mod=vendor ./vendor/...

# Add the code.
ADD . /app/

# Compile.
RUN go build -v -mod=vendor -o /a.out

ENTRYPOINT reflex $(cat .reflex) -- go run --mod=vendor main.go

# Create a production image with just the binary and cacerts.
#FROM scratch

# Copy over the ca certificates for ssl and the binary.
#COPY --from=builder /etc/ssl /etc/ssl
#COPY --from=builder /a.out /a.out

#ENTRYPOINT ["/a.out"]
