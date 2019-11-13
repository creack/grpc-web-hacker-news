package main

import (
	"context"

	hackernews_pb "github.com/easyCZ/grpc-web-hacker-news/server/proto"
	"google.golang.org/grpc"
)

func main() {
	ctx := context.Background()

	conn, err := grpc.Dial("localhost:8901", grpc.WithInsecure(), grpc.WithUserAgent("application/grpc"))
	if err != nil {
		panic(err)
	}

	storyStream, err := hackernews_pb.NewHackerNewsServiceClient(conn).ListStories(ctx, &hackernews_pb.ListStoriesRequest{})
	if err != nil {
		panic(err)
	}
loop:
	resp, err := storyStream.Recv()
	if err != nil {
		panic(err)
	}
	println(resp.GetStory().GetTitle())
	goto loop
}
