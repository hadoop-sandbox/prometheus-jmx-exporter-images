# syntax=docker/dockerfile:1.3
ARG java_version=8

FROM curlimages/curl AS download
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"
RUN install -d /home/curl_user/dists
RUN echo "Downloading Prometheus jmx_exporter" && \
  curl -fsSLo '/home/curl_user/dists/jmx_prometheus_httpserver.jar' 'https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_httpserver/0.17.2/jmx_prometheus_httpserver-0.17.2.jar' && \
  echo 'c2ae0425cfe7c7d8ec8c9ab4dff9f6c09ef3558e28469804d018148541126809 */home/curl_user/dists/jmx_prometheus_httpserver.jar' | sha256sum -c -

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

