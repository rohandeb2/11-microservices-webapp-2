# This stage is only used to compile the Go application.
FROM golang:1.21.3-alpine AS builder

# Because Alpine is minimal, we install tools needed during the build.
RUN apk add --no-cache ca-certificates git build-base

WORKDIR /src

# These files define Go dependencies.
COPY go.mod go.sum ./

#This downloads all required Go libraries.
RUN go mod download

# Copy source code
COPY . .

# This compiles the application into a binary.
# -ldflags="-s -w" Removes: debug information, symbol tables
#-gcflags This is used for development tools like Skaffold.
ARG SKAFFOLD_GO_GCFLAGS
RUN CGO_ENABLED=0 go build \
    -gcflags="${SKAFFOLD_GO_GCFLAGS}" \
    -ldflags="-s -w" \
    -o /frontend .


FROM gcr.io/distroless/static-debian12:latest

WORKDIR /app

# Copy binary and static assets from builder
COPY --from=builder /frontend ./server
COPY --from=builder /src/templates ./templates
COPY --from=builder /src/static ./static

# Controls Go stack trace output.
ENV GOTRACEBACK=single \
    PORT=8080

# Security: Distroless static images run as non-root by default (uid 65532)
USER nonroot:nonroot

EXPOSE 8080

# Execute the binary
ENTRYPOINT ["/app/server"]
