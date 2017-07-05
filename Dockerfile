# base-centos7
FROM openshift/base-centos7

MAINTAINER Michal Terbert <michal.terbert@ing.com>

ENV   BUILDER_VERSION=1.0 \
      HOME=/opt/app-root/src \
      INFLUX_VERSION=1.2.4 \
      GRAF_VERSION=4.4.0

LABEL io.k8s.description="Platform for building Grafana with InfluxDB" \
      io.k8s.display-name="INFLUXDB ${INFLUX_VERSION} GRAFANA ${GRAF_VERSION}" \
      io.openshift.expose-services="8086:http,3000:httpui" \
      io.openshift.tags="builder,influxdb,grafana,metrics"

#Install INFLUX & Supervisior
RUN  wget -q https://dl.influxdata.com/influxdb/releases/influxdb-${INFLUX_VERSION}.x86_64.rpm && \
     rpm -ivh influxdb-${INFLUX_VERSION}.x86_64.rpm && \
     rm -f influxdb-${INFLUX_VERSION}.x86_64.rpm && \
     yum install -y python-setuptools tar && \
     easy_install supervisor && yum clean all -y

#Install GRAFANA
RUN  mkdir /opt/grafana && cd /opt/grafana && \
     wget -q https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-${GRAF_VERSION}.linux-x64.tar.gz && \
     tar -xf grafana-${GRAF_VERSION}.linux-x64.tar.gz -C /opt/grafana/ && \
     mv /opt/grafana/grafana-${GRAF_VERSION}/* /opt/grafana/ && \
     rm -f /opt/grafana/grafana-${GRAF_VERSION}.linux-x64.tar.gz

COPY ./.s2i/bin/ /usr/libexec/s2i

COPY ./test/test-app/config/supervisord.conf /etc/supervisord.conf

RUN chown -R 1001:0 /opt/grafana /var/lib/influxdb /opt/app-root/ /etc/influxdb /etc/supervisord.conf

USER 1001

EXPOSE 8086
EXPOSE 3000

VOLUME /var/lib/influxdb

CMD ["/usr/libexec/s2i/usage"]
