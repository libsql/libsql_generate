FROM rust:alpine3.15

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache git python3 py3-pip bash linux-headers 
RUN rustup component add rustfmt
RUN cargo install rust-code-analysis-cli

RUN pip install --upgrade pip
RUN pip install flask gunicorn

RUN git clone https://github.com/psarna/libsql_generate.git .

ENTRYPOINT gunicorn --workers 1 --bind 0.0.0.0:8080 wsgi:app
