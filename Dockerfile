# ============
#
# Build stage
#
# ============
FROM bitwalker/alpine-elixir:1.6.1 as builder

ENV MIX_ENV=prod

WORKDIR /opt/app

RUN apk update && \
    apk --no-cache --update upgrade busybox musl && \
    apk --no-cache --update add git make g++ curl && \
    rm -rf /var/cache/apk/*

COPY config/* config/
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .

RUN mix release --env=prod --no-tar

# ============
#
# Deploy stage
#
# ============
FROM bitwalker/alpine-elixir:1.6.1

EXPOSE 4000

ENV PORT=4000 MIX_ENV=prod REPLACE_OS_VARS=true SHELL=/bin/sh

COPY --from=builder /opt/app/_build/prod/rel/demo /opt/app

ENTRYPOINT ["/opt/app/bin/demo"]
CMD ["foreground"]

