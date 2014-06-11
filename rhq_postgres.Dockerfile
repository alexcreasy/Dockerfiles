FROM fedora:20

MAINTAINER Alex Creasy <acreasy@redhat.com>

RUN yum -y install postgresql-server

# Initialise the database and make it listen to connections from the host.
USER postgres
RUN pg_ctl initdb -D /var/lib/pgsql/data
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/pgsql/data/pg_hba.conf
RUN echo "listen_addresses='*'" >> /var/lib/pgsql/data/postgresql.conf

# Create rhqadmin user and rhq database
RUN pg_ctl start -w -t 30 -D /var/lib/pgsql/data;\
    psql -c "CREATE USER rhqadmin WITH PASSWORD 'rhqadmin';";\
    psql -c "CREATE DATABASE rhq OWNER rhqadmin;";\
    pg_ctl stop -D /var/lib/pgsql/data

ENTRYPOINT ["postgres", "-D", "/var/lib/pgsql/data", "-c", "config_file=/var/lib/pgsql/data/postgresql.conf"]
EXPOSE 5432
