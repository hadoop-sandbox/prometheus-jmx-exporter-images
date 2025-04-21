# syntax=docker/dockerfile:1
ARG java_version=8

FROM scratch AS download
ADD --checksum=sha256:db024e5ae8c9882c201d8c97d9b713a0b9366d9dba07cf964899a3e4c53c6dd7 https://github.com/prometheus/jmx_exporter/releases/download/1.2.0/jmx_prometheus_standalone-1.2.0.jar /dists/jmx_prometheus_standalone.jar

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
  install -o root -g root -m 644 /dists/jmx_prometheus_standalone.jar /usr/share/jmx_exporter
COPY --chown=root:root ./jmx_exporter /usr/bin/jmx_exporter
WORKDIR /
USER prometheus
ENTRYPOINT ["/usr/bin/jmx_exporter"]

