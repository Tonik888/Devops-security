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
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

RUN yarn build

# Stage 2: Use an older vulnerable Nginx alpine image
FROM nginx:1.18.0-alpine

WORKDIR /usr/share/nginx/html

RUN rm -rf ./*

COPY --from=builder /app/dist .

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]
