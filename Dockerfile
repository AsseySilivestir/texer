# ─── Stage 1: Build the Bantu compiler from source ───────────
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        g++ \
        gcc \
        make \
        binutils \
        file \
        git \
        libsqlite3-dev \
        libcurl4-openssl-dev \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone the Bantu compiler and build it
RUN git clone https://github.com/AsseySilivestir/Bantu.git bantu-src \
    && cd /build/bantu-src/compiler \
    && chmod +x build.sh \
    && ./build.sh \
    && cp build/bantu /build/bantu


# ─── Stage 2: Runtime ─────────────────────────────────────────
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libsqlite3-0 \
        libcurl4 \
        ca-certificates \
        sqlite3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /build/bantu /usr/local/bin/bantu
COPY main.b /app/main.b
COPY bantu.json /app/bantu.json
COPY public/ /app/public/

RUN chmod +x /usr/local/bin/bantu

RUN mkdir -p /data && chmod 777 /data

# Railway injects $PORT — default to 8080 for local testing
ENV PORT=8080

EXPOSE ${PORT}

CMD ["bantu", "run", "main.b"]
