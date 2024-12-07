# syntax=docker/dockerfile:1
ARG java_version=8

FROM scratch AS download
ADD --checksum=sha256:67f23ccfdb3cab9c5f8168cd88872271df1111ebcb4527977b601ddab40e2c43 https://github.com/prometheus/jmx_exporter/releases/download/1.1.0/jmx_prometheus_standalone-1.1.0.jar /dists/jmx_prometheus_standalone.jar

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

