FROM amazonlinux:2
LABEL maintainer="Nate Wilken <wilken@asu.edu>"

RUN yum update -y && \
    yum install -y krb5-server krb5-libs && \
    yum clean all -y && \
    rm -rf /var/cache/yum /var/log/yum.log

RUN mkdir /docker-entrypoint-init.d

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

COPY krb5.conf /etc/
COPY kdc.conf /var/kerberos/krb5kdc/
COPY kadm5.acl /var/kerberos/krb5kdc/

RUN kdb5_util -r ASU.EDU -P password create -s

EXPOSE 88

CMD ["/usr/sbin/krb5kdc", "-n"]