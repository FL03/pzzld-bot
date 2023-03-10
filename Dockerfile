FROM rust:latest as base

RUN apt-get update -y && apt-get upgrade -y

FROM base as builder-base

RUN apt-get install -y \
    clang \
    libssl-dev \
    pkg-config \
    protobuf-compiler

RUN rustup update

FROM builder-base as builder

ENV CARGO_TERM_COLOR=always

ADD . /workspace
WORKDIR /workspace

COPY . .
RUN cargo xtask build --release

# FROM debian:buster-slim as runner-base

# RUN apt-get update -y && apt-get upgrade -y

# RUN apt-get install -y \
#     clang \
#     libssl-dev \
#     pkg-config \
#     protobuf-compiler

FROM builder-base as runner

ENV OPENAI_API_KEY=""\
    RUST_LOG="info" \
    TELOXIDE_TOKEN=""

COPY --chown=55 .config /config
VOLUME [ "/config" ]

COPY --from=builder /workspace/target/release/pzzldbot /bin/pzzldbot

FROM runner

CMD [ "pzzldbot" ]
