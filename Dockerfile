# ─── Stage 1: Download the pre-built Bantu binary ───────────
FROM ubuntu:24.04 AS builder

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
# Ubuntu 24.04 for GLIBCXX_3.4.32 (needed by the Bantu binary)
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libsqlite3-0 \
        libcurl4t64 \
        ca-certificates \
        sqlite3 \
        patchelf \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /build/bantu /usr/local/bin/bantu

# The binary was linked against libcurl-gnutls, but Ubuntu 24.04 only
# ships libcurl4t64 (OpenSSL backend).  patchelf re-points the DT_NEEDED
# entry so the linker loads the available libcurl.so.4 instead.
RUN patchelf --replace-needed libcurl-gnutls.so.4 libcurl.so.4 /usr/local/bin/bantu

COPY main.b /app/main.b
COPY bantu.json /app/bantu.json
COPY public/ /app/public/

RUN mkdir -p /data && chmod 777 /data

# Pre-flight: verify the binary links correctly and starts
RUN ldd /usr/local/bin/bantu && /usr/local/bin/bantu --version

# Railway injects $PORT — default to 8080 for local testing
ENV PORT=8080

EXPOSE 8080

CMD ["bantu", "run", "main.b"]