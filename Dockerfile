FROM --platform=${BUILDPLATFORM} mirror.gcr.io/denoland/deno:latest AS builder

ARG TZ=UTC
ENV TZ=${TZ}

WORKDIR /app
USER deno
COPY . .
RUN deno cache main.ts



FROM --platform=${BUILDPLATFORM} mirror.gcr.io/denoland/deno:latest

ARG TZ=UTC
ENV TZ=${TZ}

WORKDIR /app
USER deno
COPY --from=builder /app .

CMD [ "run", "--allow-net", "main.ts" ]
