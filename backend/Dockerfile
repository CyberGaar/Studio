# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

FROM node:22.20.0-alpine@sha256:dbcedd8aeab47fbc0f4dd4bffa55b7c3c729a707875968d467aaaea42d6225af AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json eslint.config.mjs ./
COPY src ./src
COPY test ./test
RUN npm run check

FROM node:22.20.0-alpine@sha256:dbcedd8aeab47fbc0f4dd4bffa55b7c3c729a707875968d467aaaea42d6225af AS runtime
ENV HOST=0.0.0.0 \
    NODE_ENV=production \
    PORT=3001
WORKDIR /app
RUN apk add --no-cache \
        libcrypto3=3.5.7-r0 \
        libssl3=3.5.7-r0 \
        musl=1.2.5-r12 \
        musl-utils=1.2.5-r12 \
        zlib=1.3.2-r0 \
    && rm -rf \
        /opt/yarn-v* \
        /usr/local/bin/corepack \
        /usr/local/bin/npm \
        /usr/local/bin/npx \
        /usr/local/bin/yarn \
        /usr/local/bin/yarnpkg \
        /usr/local/lib/node_modules/corepack \
        /usr/local/lib/node_modules/npm
COPY --from=build --chown=node:node /app/dist ./dist
USER node
EXPOSE 3001
CMD ["node", "dist/src/index.js"]
