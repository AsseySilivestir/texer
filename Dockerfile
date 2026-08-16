# ─── Stage 1: Build the Bantu binary ──────────────────────────
FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential g++ gcc make binutils file \
        libsqlite3-dev libcurl4-openssl-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /build
COPY bantu-src/compiler/ /build/compiler/
RUN cd /build/compiler && chmod +x build.sh && ./build.sh \
    && cp build/bantu /build/bantu

# ─── Stage 2: Runtime ──────────────────────────────────────────────
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends \
        libsqlite3-0 libcurl4 ca-certificates sqlite3 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /build/bantu /usr/local/bin/bantu
COPY main.b /app/main.b
COPY public/ /app/public/
RUN mkdir -p /data && chmod 777 /data
ENV PORT=8080
EXPOSE 8080
CMD ["bantu", "run", "main.b"]
