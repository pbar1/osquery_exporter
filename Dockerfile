FROM golang:1 as build
WORKDIR /src
COPY . .
RUN go build .

FROM debian:11-slim
LABEL org.opencontainers.image.source https://github.com/pbar1/osquery_exporter
COPY --from=build /src/osquery_exporter /usr/local/bin/
ENV OSQUERY_KEY=1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
RUN apt-get update && \
    apt-get install gnupg2 software-properties-common --yes && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $OSQUERY_KEY && \
    add-apt-repository 'deb [arch=amd64] https://pkg.osquery.io/deb deb main' && \
    apt-get update && \
    apt-get install osquery --yes && \
    apt-get remove gnupg software-properties-common --yes && \
    apt-get autoremove --yes
ENTRYPOINT ["/usr/local/bin/osquery_exporter"]
