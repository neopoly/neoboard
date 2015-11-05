FROM alpine:edge
MAINTAINER Jonas Thiel <jonas@thiel.io>

RUN echo 'http://dl-4.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories

RUN apk --update add ncurses-libs erlang wget curl erlang-crypto build-base libstdc++\
    erlang-syntax-tools erlang-inets erlang-ssl erlang-public-key erlang-xmerl\
    erlang-asn1 erlang-sasl erlang-erl-interface erlang-dev nodejs git python\
    && rm -rf /var/cache/apk/*

ENV ELIXIR_VERSION 1.1.1

RUN curl -L -o Precompiled.zip https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip \
    && mkdir -p /opt/elixir-${ELIXIR_VERSION}/ \
    && unzip Precompiled.zip -d /opt/elixir-${ELIXIR_VERSION}/ \
    && rm Precompiled.zip

ENV PATH $PATH:/opt/elixir-${ELIXIR_VERSION}/bin

RUN mix local.hex --force \
    && mix local.rebar --force

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY package.json $APP_HOME/package.json

ENV SASS_BINARY_NAME alpine-x64-14
ENV SASS_BINARY_SITE https://github.com/jnbt/node-sass/releases/download
RUN npm install

ENV MIX_ENV prod
ENV NEOBOARD_PORT 4000

COPY ["mix.exs", "mix.lock", "${APP_HOME}/"]
RUN mix deps.get

COPY config ${APP_HOME}/config
COPY lib ${APP_HOME}/lib
COPY test ${APP_HOME}/test
COPY web ${APP_HOME}/web
COPY priv ${APP_HOME}/priv
RUN mix compile

COPY webpack.config.js $APP_HOME/webpack.config.js
RUN mkdir -p priv/static \
    && node_modules/webpack/bin/webpack.js -p --progress \
    && mix phoenix.digest

EXPOSE 4000

CMD ["mix", "phoenix.server"]
