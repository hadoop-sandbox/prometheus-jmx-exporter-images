# syntax=docker/dockerfile:1
ARG java_version=8

FROM scratch AS download
ADD --checksum=sha256:533b5fb1256976a5e361f6263093ebc55763cc9ff0778ee630373e1d2649f92f https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_httpserver/1.0.0/jmx_prometheus_httpserver-1.0.0.jar /dists/jmx_prometheus_httpserver.jar

FROM eclipse-temurin:${java_version}-jre AS prometheus-jmx-exporter
RUN --mount=type=bind,from=download,source=/dists,target=/dists \
  groupadd -r -g 800 prometheus && \
  useradd -r -u 800 -g prometheus -Ms /sbin/nologin -d /nonexistant prometheus && \
  install -d -o root -g root -m 755 /usr && \
  install -d -o root -g root -m 755 /usr/share && \
  install -d -o root -g root -m 755 /usr/share/jmx_exporter && \
  install -d -o root -g root -m 755 /usr/bin && \
  install -d -o root -g root -m 755 /etc && \
  install -d -o root -g root -m 755 /etc/jmx_exporter && \
  install -o root -g root -m 644 /dists/jmx_prometheus_httpserver.jar /usr/share/jmx_exporter
COPY --chown=root:root ./jmx_exporter /usr/bin/jmx_exporter
WORKDIR /
USER prometheus
ENTRYPOINT ["/usr/bin/jmx_exporter"]

