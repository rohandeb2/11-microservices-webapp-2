FROM golang:1.21.3-alpine AS builder

#Because Alpine is minimal, we install some tools.
RUN apk add --no-cache ca-certificates git build-base

WORKDIR /src

#These files define Go dependencies and module information.
COPY go.mod go.sum ./

#This downloads all required Go modules.
RUN go mod download

COPY . .

#This compiles the Go program into a single executable binary.
#CGO_ENABLED=0 --> This disables C dependencies.
RUN CGO_ENABLED=0 go build -o /checkoutservice .

# Final Stage
FROM gcr.io/distroless/static-debian12
# Copy directly from the builder's root to the final root

#This copies the compiled binary from the builder stage.
COPY --from=builder /checkoutservice /checkoutservice

USER nonroot:nonroot

ENTRYPOINT ["/checkoutservice"]

#Distroless images remove unnecessary OS utilities like shells and package
# managers, reducing the attack surface and making containers more secure and smaller.