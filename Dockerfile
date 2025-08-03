FROM mirror.gcr.io/denoland/deno:2.4.3

ARG TZ
ENV TZ=${TZ}

WORKDIR /app

USER deno

COPY deps.ts .
RUN deno install --entrypoint deps.ts

COPY . .
RUN deno cache main.ts

CMD [ "run", "--allow-net", "main.ts" ]
