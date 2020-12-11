FROM golang AS builder

WORKDIR /build
RUN git clone https://github.com/Cloudbox/autoscan.git /build && \
    mkdir -p dist/ && \
    go mod vendor && \
    go mod tidy && \
    CGO_ENABLED=1 GOOS=linux GOARCH=arm go build \
    -o /build/autoscan -ldflags "-linkmode external -extldflags -static" -a \
    ./cmd/autoscan && \
    chmod +x /build/autoscan

FROM scratch
ENV \
  PATH="/app/autoscan:${PATH}" \
  AUTOSCAN_CONFIG="/config/config.yml" \
  AUTOSCAN_DATABASE="/config/autoscan.db" \
  AUTOSCAN_LOG="/config/activity.log" \
  AUTOSCAN_VERBOSITY="0"

# Copy binary
COPY --from=builder /build/autoscan /app/autoscan/autoscan

# Run the hello binary.
ENTRYPOINT ["/app/autoscan/autoscan"]

# Volume
VOLUME ["/config"]

# Port
EXPOSE 3030
