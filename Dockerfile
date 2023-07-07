# syntax=docker/dockerfile:1.3
ARG java_version=8

FROM curlimages/curl AS download
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"
RUN install -d /home/curl_user/dists
RUN echo "Downloading Prometheus jmx_exporter" && \
  curl -fsSLo '/home/curl_user/dists/jmx_prometheus_httpserver.jar' 'https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_httpserver/0.19.0/jmx_prometheus_httpserver-0.19.0.jar' && \
  echo '90b0a710b1f8ddce7e24b5023fba4e0d0481decd2bed8072f89844d8baf206ce */home/curl_user/dists/jmx_prometheus_httpserver.jar' | sha256sum -c -

FROM eclipse-temurin:${java_version}-jre AS prometheus-jmx-exporter
RUN --mount=type=bind,from=download,source=/home/curl_user/dists,target=/home/curl_user/dists \
  groupadd -r -g 800 prometheus && \
  useradd -r -u 800 -g prometheus -Ms /sbin/nologin -d /nonexistant prometheus && \
  install -d -o root -g root -m 755 /usr && \
  install -d -o root -g root -m 755 /usr/share && \
  install -d -o root -g root -m 755 /usr/share/jmx_exporter && \
  install -d -o root -g root -m 755 /usr/bin && \
  install -d -o root -g root -m 755 /etc && \
  install -d -o root -g root -m 755 /etc/jmx_exporter && \
  install -o root -g root -m 644 /home/curl_user/dists/jmx_prometheus_httpserver.jar /usr/share/jmx_exporter
COPY --chown=root:root ./jmx_exporter /usr/bin/jmx_exporter
WORKDIR /
USER prometheus
ENTRYPOINT ["/usr/bin/jmx_exporter"]

