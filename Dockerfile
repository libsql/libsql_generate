FROM rust:alpine

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache git python3 py3-pip bash musl-dev binaryen build-base
RUN apk add --no-cache wabt --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
RUN rustup component add rustfmt
RUN cargo install rust-code-analysis-cli

RUN pip3 install --upgrade pip
RUN pip3 install flask gunicorn flask-cors

RUN rustup target add wasm32-unknown-unknown

RUN git clone https://github.com/psarna/libsql_generate.git .

RUN ./generate.sh

ENTRYPOINT while true; do gunicorn --workers 1 --bind 0.0.0.0:8080 wsgi:app; done
