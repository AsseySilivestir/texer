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

# Runtime libs + build tools (needed to compile libcurl-gnutls from source)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libsqlite3-0 \
        ca-certificates \
        sqlite3 \
        build-essential \
        libgnutls28-dev \
        pkg-config \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Build libcurl with GnuTLS backend from source.
# Ubuntu 24.04 no longer ships libcurl-gnutls, but the Bantu binary
# requires CURL_GNUTLS_3 symbols only found in the GnuTLS build.
RUN cd /tmp \
    && wget -q https://curl.se/download/curl-8.5.0.tar.gz \
    && tar xzf curl-8.5.0.tar.gz \
    && cd curl-8.5.0 \
    && ./configure --with-gnutls --without-openssl --disable-docs --disable-manual \
    && make -j"$(nproc)" \
    && make install \
    && ldconfig \
    && ln -sf /usr/local/lib/libcurl.so.4 /usr/local/lib/libcurl-gnutls.so.4 \
    && rm -rf /tmp/curl-*

# Clean up build tools to reduce image size
RUN apt-get purge -y --auto-remove build-essential libgnutls28-dev pkg-config wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /build/bantu /usr/local/bin/bantu
COPY main.b /app/main.b
COPY bantu.json /app/bantu.json
COPY public/ /app/public/

RUN mkdir -p /data && chmod 777 /data

# Ensure the custom-built libcurl-gnutls is found first
ENV LD_LIBRARY_PATH=/usr/local/lib

# Pre-flight: verify the binary links correctly and starts
RUN ldd /usr/local/bin/bantu && /usr/local/bin/bantu --version

# Railway injects $PORT — default to 8080 for local testing
ENV PORT=8080

EXPOSE 8080

CMD ["bantu", "run", "main.b"]