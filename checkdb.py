#!/usr/bin/env python

import sys
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

#    conn=psycopg2.connect(host=sys.argv[1],database=sys.argv[2], user=sys.argv[3], password=sys.argv[4], port=sys.argv[5])
createuser = """CREATE USER %s WITH PASSWORD '%s';
ALTER USER %s SUPERUSER;""" % (sys.argv[3], sys.argv[4],sys.argv[3])

checkuser = """SELECT COUNT(*) = 0 FROM pg_roles WHERE rolname='%s';""" % (sys.argv[3])

createdatabase = """CREATE DATABASE %s WITH OWNER = '%s';""" % (sys.argv[2], sys.argv[3])

checkdatabase = """SELECT COUNT(*) = 0 FROM pg_catalog.pg_database WHERE datname = '%s';""" % (sys.argv[2])

try:
#    conn=psycopg2.connect(host="localhost",database="postgres", user="postgres", password="" , port="5432")
    conn=psycopg2.connect(host=sys.argv[1],database="postgres", user=sys.argv[6], password=sys.argv[7], port=sys.argv[5])
    cursor = conn.cursor()
    print ("database connection succesful")

    cursor.execute(checkuser)
    user_not_exist_row = cursor.fetchone()
    user_not_exist = user_not_exist_row[0]

    if user_not_exist:
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        print (createuser)
        cursor.execute(createuser)
    else:
        print ("user exists")

    cursor.execute(checkdatabase) 
    db_not_exist_row = cursor.fetchone()
    db_not_exist = db_not_exist_row[0]

    if db_not_exist:
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        print (createdatabase)
        cursor.execute(createdatabase)
    else:
        print ("database exists")


except (Exception, psycopg2.Error) as error :
    print ("Error while connecting to PostgreSQL", error)
finally:
    #closing database connection.
        if(conn):
            cursor.close()
            conn.close()
            print("PostgreSQL connection is closed")



#try the connection

#