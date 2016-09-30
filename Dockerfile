FROM alpine:3.4
MAINTAINER Jonas Thiel <jonas@thiel.io>

RUN apk --update add ncurses-libs curl build-base libstdc++ erlang erlang-crypto\
    erlang-syntax-tools erlang-inets erlang-ssl erlang-public-key erlang-xmerl\
    erlang-asn1 erlang-sasl erlang-erl-interface erlang-dev erlang-parsetools\
    nodejs git python\
    && rm -rf /var/cache/apk/*

ENV ELIXIR_VERSION 1.2.0

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
