# libSQL bindgen generator

This repository contains a Web application based on [libSQL bindgen](https://crates.io/crates/libsql_bindgen), allowing its users to compile
Rust code right into WebAssembly compatible with user-defined functions for [libSQL](https://libsql.org).

It consists of a backend service which compiles Rust code to WebAssembly (see the Dockerfile for details)
and a simple static page serving as frontend.

Official mirror is hosted at https://libsql-bindgen.sarna.dev

Deploy your own instance by running fly.io's `flyctl deploy`, the `fly.toml` file is already here for your convenience.
