FROM python:slim-buster

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt install -y git

RUN pip install --upgrade pip
RUN pip install flask gunicorn psycopg2-binary

RUN git clone git@github.com:psarna/libsql_generate.git

ENTRYPOINT gunicorn --workers 1 --bind localhost:5001 wsgi:app
