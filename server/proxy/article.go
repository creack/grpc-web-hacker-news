package proxy

import (
	"io"
	"log"
	"net/http"
)

func Article(w http.ResponseWriter, req *http.Request) {
	ctx := req.Context()

	queryValues := req.URL.Query()
	url := queryValues.Get("q")
	if url == "" {
		http.Error(w, "Must specify the url to request", http.StatusBadRequest)
		return
	}
	proxyReq, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		http.Error(w, "Invalid url to request", http.StatusBadRequest)
		return
	}
	proxyReq = proxyReq.WithContext(ctx)
	resp, err := (&http.Client{}).Do(proxyReq)
	if err != nil {
		http.Error(w, "Failed to retrieve article", http.StatusInternalServerError)
		return
	}
	if resp.StatusCode >= 400 {
		if err != nil {
			http.Error(w, resp.Status, resp.StatusCode)
			return
		}
	}
	if _, err := io.Copy(w, resp.Body); err != nil {
		log.Printf("Error sending body to client: %s.\n", err)
		return
	}
}
