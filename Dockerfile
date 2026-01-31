FROM docker.io/alpine:3.21 as brother_ql

RUN apk add --no-cache git
RUN mkdir -p /opt
RUN git clone https://github.com/LunarEclipse363/brother_ql_next/ /opt/brother_ql
WORKDIR /opt/brother_ql
RUN git checkout af3e6c7648ee972c17cafbfe22d29e83d6458a2a # v0.11.4
RUN rm -rf .git

FROM ghcr.io/sysadminsmedia/homebox:0.23.0 as homebox

FROM docker.io/python:3.13-alpine3.21

COPY --from=brother_ql /opt/brother_ql/ /opt/brother_ql/
WORKDIR /opt/brother_ql
RUN pip install --no-cache-dir .

RUN apk add --no-cache wget ca-certificates
COPY --from=homebox /app /app

LABEL Name="homebox-brother-ql"
LABEL Version="0.23.0+brother-ql-0-11-4"

ENV HBOX_MODE=production
ENV HBOX_STORAGE_CONN_STRING=file:///?no_tmp_dir=true
ENV HBOX_STORAGE_PREFIX_PATH=data
ENV HBOX_DATABASE_SQLITE_PATH=/data/homebox.db?_pragma=busy_timeout=2000&_pragma=journal_mode=WAL&_fk=1&_time_format=sqlite

WORKDIR /app
EXPOSE 7745

VOLUME [ "/data" ]

ENTRYPOINT [ "/app/api" ]
CMD [ "/data/config.yml" ]
