# rhel7-elasticsearch
FROM openshift/base-centos7

MAINTAINER Michal Terbert <michal.terbert@ing.com>

# TODO: Rename the builder environment variable to inform users about application you provide them
ENV   BUILDER_VERSION=1.0 \
      HOME=/opt/app-root/src \
      INFLUX_VERSION=1.2.1\
      GRAF_VERSION=4.1.2-1486989747

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building Grafana with InfluxDB" \
      io.k8s.display-name="INFLUXDB ${INFLUX_VERSION} GRAFANA ${GRAF_VERSION}" \
      io.openshift.expose-services="8086:http,3000:httpui" \
      io.openshift.tags="builder,influxdb,grafana,metrics"

# TODO: Install required packages here:
#Install INFLUX
RUN  wget -q https://dl.influxdata.com/influxdb/releases/influxdb-${INFLUX_VERSION}.x86_64.rpm && \
     rpm -ivh influxdb-${INFLUX_VERSION}.x86_64.rpm && \
     rm -f influxdb-${INFLUX_VERSION}.x86_64.rpm && \
     yum install -y python-setuptools tar && \
     easy_install supervisor && yum clean all -y

#Install GRAFANA
RUN  mkdir /opt/grafana && cd /opt/grafana && \
     wget -q https://grafanarel.s3.amazonaws.com/builds/grafana-${GRAF_VERSION}.linux-x64.tar.gz && \
     tar -xvf grafana-${GRAF_VERSION}.linux-x64.tar.gz -C /opt/grafana/ &&\
     mv /opt/grafana/grafana-${GRAF_VERSION}/* /opt/grafana/ &&\
     rm -f /opt/grafana/grafana-${GRAF_VERSION}.linux-x64.tar.gz

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./.s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:0 /opt/grafana /var/lib/influxdb

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8086
EXPOSE 3000

VOLUME /var/lib/influxdb
# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
