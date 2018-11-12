#!/bin/bash

set -e



        if [ -z "$DJANGOCMS_DB_HOST" ]; then
                export DJANGOCMS_DB_HOST='postgres'
        else
                echo >&2 "   DJANGOCMS_DB_HOST  found"
                echo >&2 "  Connecting to DJANGOCMS_DB_HOST ($DJANGOCMS_DB_HOST)"
                echo >&2 "  instead of a postgres container"
        fi


        if [ -z "$DJANGOCMS_ADMIN_DB_USER" ] && [ -z "$DJANGOCMS_ADMIN_DB_PWD" ]; then
                export DJANGOCMS_ADMIN_DB_USER='postgres'
                export DJANGOCMS_ADMIN_DB_PASSWORD=''
                echo >&2 "  this assumes the admin DJANGOCMS_ADMIN_DB_USER is postgres and the password is empty"
                echo >&2 "  this is a security hazard, kindly change"
                echo >&2 "  You may notice a password is not required when connecting from localhost (inside the same container)"
                echo >&2 "  this is becauseThe PostgreSQL image sets up trust authentication locally therefor  "
                echo >&2 "  a password will be required if connecting from a different host/container"
                echo >&2 "  Use -e POSTGRES_PASSWORD=password to set it in the docker run of your postgres db if its a container"
        else
                echo >&2 "  warning: DJANGOCMS_ADMIN_DB_USER not found this is needed to bootstrap the db"
                echo >&2 "  pls supply with -e DJANGOCMS_ADMIN_DB_USER=?"
                echo >&2 "  and -e DJANGOCMS_ADMIN_DB_PASSWORD=?"
        fi

        if [ -z "$DJANGOCMS_ADMIN_DB_USER" ]; then
                export DJANGOCMS_ADMIN_DB_USER='postgres'
                echo >&2 "  this assumes the admin DJANGOCMS_ADMIN_DB_USER is postgres "
        else
                echo >&2 "  warning: DJANGOCMS_ADMIN_DB_USER not found this is needed to bootstrap the db"
                echo >&2 "  pls supply with -e DJANGOCMS_ADMIN_DB_USER=?"
                echo >&2 "  and -e DJANGOCMS_ADMIN_DB_PASSWORD=?"
        fi

        if [ -z "$DJANGOCMS_DB_PORT" ]; then
                export DJANGOCMS_DB_PORT=5432
        else
                echo >&2 "  warning: You're specifying a different port different from the postgres default 5432 "
        fi

        # If the DB user is 'root' then use the MySQL root password env var
        : ${DJANGOCMS_DB_USER:=djangocms}
        : ${DJANGOCMS_DB_PWD:=djangocms}
        : ${DJANGOCMS_DB_NAME:=djangocms}

        export DJANGOCMS_DB_USER DJANGOCMS_DB_PWD DJANGOCMS_DB_NAME


        # Ensure the MySQL Database is create

        python checkdb.py "$DJANGOCMS_DB_HOST" "$DJANGOCMS_DB_NAME" "$DJANGOCMS_DB_USER" "$DJANGOCMS_DB_PWD" "$DJANGOCMS_DB_PORT" "$DJANGOCMS_ADMIN_DB_USER" "$DJANGOCMS_ADMIN_DB_PWD" 

        echo >&2 "========================================================================"
        echo >&2
        echo >&2 "This server is now configured to run djangocms!"
        echo >&2
        echo >&2
        echo >&2 "========================================================================"

        # popualte settings.py template file

        sed -i "s/mysite/$1/g" $1/settings.py

        python manage.py collectstatic --noinput
        python manage.py migrate
        python manage.py runserver 0.0.0.0:80
