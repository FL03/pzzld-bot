FROM rust:latest as base

RUN apt-get update -y && apt-get upgrade -y

FROM base as builder-base

RUN rustup update

FROM builder-base as builder

ENV CARGO_TERM_COLOR=always

ADD . /workspace
WORKDIR /workspace

COPY . .
RUN cargo build --release -v --workspace

FROM debian:buster-slim as runner-base

ENV RUST_LOG="info" \
    SERVER_PORT=8080

RUN apt-get update -y && apt-get upgrade -y

RUN mkdir data
VOLUME [ "/data" ]

COPY --chown=55 .config /config
VOLUME [ "/config" ]

COPY --chown=55 --from=builder /workspace/target/release/tldr /bin/tldr

FROM runner-base as runner

EXPOSE 80
EXPOSE ${SERVER_PORT}

ENTRYPOINT [ "tldr" ]
CMD [ "-h" ]