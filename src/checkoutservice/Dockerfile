FROM golang:1.21.3-alpine AS builder
RUN apk add --no-cache ca-certificates git build-base
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /checkoutservice .

# Final Stage
FROM gcr.io/distroless/static-debian12
# Copy directly from the builder's root to the final root
COPY --from=builder /checkoutservice /checkoutservice
USER nonroot:nonroot
ENTRYPOINT ["/checkoutservice"]
