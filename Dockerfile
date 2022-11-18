FROM rust:slim-buster

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update
RUN apt-get install -y git python3 python3-pip bash binaryen build-essential wabt

RUN rustup default nightly
RUN rustup self update
RUN rustup update
RUN rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu

RUN rustup component add rustfmt
RUN cargo install rust-code-analysis-cli

RUN pip3 install --upgrade pip
RUN pip3 install flask gunicorn flask-cors

RUN rustup target add wasm32-unknown-unknown

RUN git clone https://github.com/psarna/libsql_generate.git .

RUN ./generate.sh

ENTRYPOINT while true; do gunicorn --workers 1 --bind 0.0.0.0:8080 wsgi:app; done
