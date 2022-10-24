FROM registry.access.redhat.com/ubi8/python-39
LABEL maintainer="Bob Kozdemba <bkozdemba@gmail.com>"

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root
RUN mkdir -p ${APP_ROOT}/{bin,src} && \
    chmod -R u+x ${APP_ROOT}/bin && chgrp -R 0 ${APP_ROOT} && chmod -R g=u ${APP_ROOT}
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}

RUN pip install mlserver mlserver_sklearn

WORKDIR ${APP_ROOT}
COPY . ${WORKDIR}

### Containers should NOT run as root as a good practice
USER 1001

EXPOSE 8080 8081 8082

VOLUME ${APP_ROOT}/logs ${APP_ROOT}/data

CMD mlserver start .
