package main

import (
	"net"
	"net/http"

	"github.com/easyCZ/grpc-web-hacker-news/server/hackernews"

	hackernews_pb "github.com/easyCZ/grpc-web-hacker-news/server/proto"
	"github.com/easyCZ/grpc-web-hacker-news/server/proxy"
	"github.com/go-chi/chi"
	chiMiddleware "github.com/go-chi/chi/middleware"
	"github.com/improbable-eng/grpc-web/go/grpcweb"
	"github.com/rs/cors"
	"google.golang.org/grpc"
	"google.golang.org/grpc/grpclog"
)

func main() {
	grpcServer := grpc.NewServer()
	hackernewsService := hackernews.NewHackerNewsService(nil)
	hackernews_pb.RegisterHackerNewsServiceServer(grpcServer, hackernewsService)

	wrappedGrpc := grpcweb.WrapServer(grpcServer)

	router := chi.NewRouter()

	router.Use(
		chiMiddleware.Logger,
		chiMiddleware.Recoverer,
		cors.New(cors.Options{
			AllowedOrigins:   []string{"*"},
			AllowedMethods:   []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodOptions},
			AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-Csrf-Token", "X-Grpc-Web"},
			ExposedHeaders:   []string{"Link"},
			AllowCredentials: true,
			MaxAge:           300, // Maximum value not ignored by any of major browsers
		}).Handler,
		//middleware.NewGrpcWebMiddleware(wrappedGrpc).Handler,
	)

	router.Handle("/*", wrappedGrpc)
	router.Get("/article-proxy", proxy.Article)

	go func() {
		lis, err := net.Listen("tcp", ":8901")
		if err != nil {
			panic(err)
		}

		println("ready1")
		if err := grpcServer.Serve(lis); err != nil {
			grpclog.Fatalf("failed starting http2 server: %v", err)
		}
	}()

	println("ready2")
	if err := http.ListenAndServe(":8900", router); err != nil {
		grpclog.Fatalf("failed starting http2 server: %v", err)
	}
}
