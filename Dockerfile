FROM amazonlinux:2
LABEL maintainer="Nate Wilken <wilken@asu.edu>"

RUN yum update -y && \
    yum install -y krb5-server krb5-libs && \
    yum clean all -y && \
    rm -rf /var/cache/yum /var/log/yum.log

RUN mkdir /docker-entrypoint-init.d

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 88

CMD ["/usr/sbin/krb5kdc", "-n"]
