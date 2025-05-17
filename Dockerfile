FROM node:16.17.0-alpine as builder
WORKDIR /app

# Copy dependency files
COPY ./package.json .
COPY ./yarn.lock .

# Intentionally install outdated vulnerable package (prototype pollution in lodash)
RUN yarn add lodash@4.17.11

# Install dependencies including vulnerable lodash
RUN yarn install

# Copy source code
COPY . .

# Build argument passed as environment variable (secret leakage)
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}

# Hardcoded secret - SonarQube will flag this as critical
ENV SECRET_API_KEY="hardcoded_secret_key_123456"

# Use insecure HTTP API endpoint - critical misconfiguration
ENV VITE_APP_API_ENDPOINT_URL="http://api.themoviedb.org/3"

# Run the build command
RUN yarn build

# Use outdated vulnerable base image for production stage
FROM nginx:1.18.0-alpine

WORKDIR /usr/share/nginx/html

# Delete existing content (clean slate)
RUN rm -rf ./*

# Copy built files
COPY --from=builder /app/dist .

# Expose insecure port (no TLS termination)
EXPOSE 80

# Run nginx in foreground
ENTRYPOINT ["nginx", "-g", "daemon off;"]
