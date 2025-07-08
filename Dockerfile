FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock ./
COPY excalidraw-app/package.json excalidraw-app/
COPY packages/common/package.json packages/common/
COPY packages/excalidraw/package.json packages/excalidraw/
COPY packages/element/package.json packages/element/
COPY packages/math/package.json packages/math/
COPY packages/utils/package.json packages/utils/

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn --cwd ./excalidraw-app build

FROM node:18-alpine

WORKDIR /app

COPY --from=builder /app/excalidraw-app/build ./excalidraw-app/build
COPY --from=builder /app/excalidraw-app/package.json ./excalidraw-app/
COPY --from=builder /app/yarn.lock ./

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000

CMD ["yarn", "--cwd", "./excalidraw-app", "start"]