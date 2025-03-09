FROM golang:1.9

WORKDIR /echo
COPY main.go .
RUN go build -o echo main.go  

CMD ["/echo/echo"] 