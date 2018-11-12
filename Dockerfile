FROM python:2.7-jessie

WORKDIR /app

ARG PROJECT_NAME
ENV PROJECT_ENDPOINT=$PROJECT_NAME

RUN set -xe \
    && pip install djangocms-installer psycopg2-binary psycopg2 \
    && mkdir -p data \
    && djangocms --db sqlite://localhost/data/project.db \
                 --filer \
                 --languages en \
                 --no-input \
                 --parent-dir . \
                 --skip-empty-check \
                 --utc \
                 $PROJECT_NAME

VOLUME /app/data

COPY settings.py ./$PROJECT_NAME/settings.py
COPY docker-entrypoint.sh ./entrypoint.sh
COPY checkdb.py ./checkdb.py

EXPOSE 80

ENTRYPOINT [ "/bin/sh",  "-c" , "./entrypoint.sh $PROJECT_ENDPOINT"]