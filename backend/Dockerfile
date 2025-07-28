FROM nimlang/nim:1.6.14-alpine AS builder

WORKDIR /app
COPY naitsabackend.nimble .
RUN nimble install -d -y

COPY src/ src/
RUN nimble build -d:release

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./naitsabackend"]
