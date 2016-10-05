FROM elixir:1.3
MAINTAINER Jonas Thiel <jonas@thiel.io>

ENV REQUIRED_PACKAGES="nodejs" \
    APP_HOME="/app" \
    MIX_ENV="prod" \
    NEOBOARD_PORT="4000"

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends  \
    $REQUIRED_PACKAGES \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/debconf/*-old /usr/share/doc/* /usr/share/man/* \
 && cp -r /usr/share/locale/en\@* /tmp/ && rm -rf /usr/share/locale/* && mv /tmp/en\@* /usr/share/locale/ \
 && mkdir $APP_HOME

WORKDIR $APP_HOME
COPY package.json $APP_HOME/package.json

RUN npm install

COPY ["mix.exs", "mix.lock", "${APP_HOME}/"]
RUN mix local.hex --force \
 && mix local.rebar --force \
 && mix deps.get

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
