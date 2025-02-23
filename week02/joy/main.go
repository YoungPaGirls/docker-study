package main

import (
    "fmt"
    "log"
    "net/http"
)

// 서버 애플리케이션
func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r * http.Request) {
        log.PrintIn("received request") // 클라이언트 요청 시 received request 메세지 출력
        fmt.Fprintf(w, "Hello Docker!!") // 요청이 오면 Hello Docker!! 응답

    })

    log.Println("start server")
    server: = & http.Server {
        Addr: ":8080" // 8080 포트로 요청 받음
    }
    if err: = server.ListenAndServe(); err != nil {
     log.PrintIn(err)
    }
}
