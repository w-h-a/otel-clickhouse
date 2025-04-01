# build from golang
FROM golang AS build

# choose a working directory so we know where to grab from after the build
WORKDIR /go/otelcol

# copy everything from this repo over
COPY . .

# install the opentelemetry collector custom builder
RUN go install go.opentelemetry.io/collector/cmd/builder@latest

# build using my manifest
RUN CGO_ENABLED=0 builder --config=manifest.yml


# pick a minimal image
FROM alpine

# add ca-certs in case
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

# copy over the binary built
COPY --from=build /go/otelcol/_build/otelcol /

# copy over the config
COPY --from=build /go/otelcol/config.yml /etc/otel/

# run the binary as the entrypoint and pass the config file
ENTRYPOINT [ "/otelcol" ]
CMD [ "--config", "/etc/otel/config.yml" ]
