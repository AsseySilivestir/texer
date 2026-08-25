# ─── Stage 1: Download the pre-built Bantu binary ───────────
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# The Bantu repo ships a pre-built Linux binary at the root — just grab it
RUN git clone https://github.com/AsseySilivestir/Bantu.git bantu-repo \
    && cp bantu-repo/bantu /build/bantu \
    && chmod +x /build/bantu


# ─── Stage 2: Runtime ─────────────────────────────────────────
FROM ubuntu:22.04

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

# Pre-flight: verify the binary works
RUN ldd /usr/local/bin/bantu && /usr/local/bin/bantu --version

# Railway injects $PORT — default to 8080 for local testing
ENV PORT=8080

EXPOSE 8080

CMD ["bantu", "run", "main.b"]