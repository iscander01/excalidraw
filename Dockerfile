FROM node:18 AS builder

WORKDIR /app

COPY package.json yarn.lock ./
COPY excalidraw-app/package.json excalidraw-app/
COPY packages/*/package.json packages/*/

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn --cwd ./excalidraw-app build

FROM node:18-slim

WORKDIR /app

COPY --from=builder /app/excalidraw-app/build ./excalidraw-app/build
COPY --from=builder /app/excalidraw-app/package.json ./excalidraw-app/package.json
COPY --from=builder /app/yarn.lock ./

RUN yarn install --production --frozen-lockfile --cwd ./excalidraw-app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

CMD ["yarn", "--cwd", "./excalidraw-app", "start"]