FROM node:24-slim AS base

ENV CI=true
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

WORKDIR /app

FROM base AS deps

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile

FROM deps AS build

COPY . .

RUN pnpm run build

FROM node:24-slim AS runtime

ENV NODE_ENV=production

WORKDIR /app

COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./

USER node
EXPOSE 3000

CMD ["node", "build"]
