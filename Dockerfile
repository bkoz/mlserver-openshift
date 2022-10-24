FROM registry.access.redhat.com/ubi8/ubi:8.1
LABEL maintainer="Bob Kozdemba <bkozdemba@gmail.com>"

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root
RUN mkdir -p ${APP_ROOT}/{bin,src} && \
    chmod -R u+x ${APP_ROOT}/bin && chgrp -R 0 ${APP_ROOT} && chmod -R g=u ${APP_ROOT}
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}

RUN yum --disableplugin=subscription-manager -y install gcc-c++ python3 python3-pip \
  && yum --disableplugin=subscription-manager clean all

### Containers should NOT run as root as a good practice
USER 1001
WORKDIR ${APP_ROOT}

# ADD index.php /var/www/html

RUN pip3 install pip mlserver mlserver_sklearn -U 

EXPOSE 8080 8082

VOLUME ${APP_ROOT}/logs ${APP_ROOT}/data

CMD mlserver start .