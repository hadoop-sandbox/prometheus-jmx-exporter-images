# syntax=docker/dockerfile:1.3
ARG java_version=8

FROM curlimages/curl AS download
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"
RUN install -d /home/curl_user/dists
RUN echo "Downloading Prometheus jmx_exporter" && \
  curl -fsSLo '/home/curl_user/dists/jmx_prometheus_httpserver.jar' 'https://repo.maven.apache.org/maven2/io/prometheus/jmx/jmx_prometheus_httpserver/0.20.0/jmx_prometheus_httpserver-0.20.0.jar' && \
  echo '19eb6ba6d5bc899cc5726d86651683e0fecb718da3190da133c48ece08d89aab */home/curl_user/dists/jmx_prometheus_httpserver.jar' | sha256sum -c -

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

