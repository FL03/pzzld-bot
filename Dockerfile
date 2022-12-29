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
RUN cargo install --path app

FROM builder as runner

ENV OPENAI_API_KEY=""\
    RUST_LOG="info" \
    SERVER_PORT=8080 \
    TELOXIDE_TOKEN=""

EXPOSE 80
EXPOSE ${SERVER_PORT}
EXPOSE 6379

FROM runner

ENTRYPOINT [ "pzzldbot" ]
CMD [ "services", "--telegram" ]
