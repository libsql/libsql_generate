FROM rust:slim-buster

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update
RUN apt-get install -y git python3 python3-pip bash
RUN rustup component add rustfmt
RUN cargo install rust-code-analysis-cli

RUN pip3 install --upgrade pip
RUN pip3 install flask gunicorn

RUN rustup target add wasm32-unknown-unknown
RUN apt-get install -y wabt binaryen

RUN git clone https://github.com/psarna/libsql_generate.git .

ENTRYPOINT gunicorn --workers 1 --bind 0.0.0.0:8080 wsgi:app
