FROM alpine:latest
WORKDIR /usr/local/bin
COPY backup_volumes_to_varlocal.sh .
RUN apk update
RUN apk add 7zip 7zip-doc bash bash-doc
RUN chmod +x /usr/local/bin/backup_volumes_to_varlocal.sh
CMD /usr/local/bin/backup_volumes_to_varlocal.sh
