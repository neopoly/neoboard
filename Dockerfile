FROM elixir:1.4
MAINTAINER Jonas Thiel <jonas@thiel.io>

ENV REQUIRED_PACKAGES="nodejs yarn" \
    APP_HOME="/app" \
    MIX_ENV="prod" \
    NEOBOARD_PORT="4000"

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends  \
    $REQUIRED_PACKAGES \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/debconf/*-old /usr/share/doc/* /usr/share/man/* \
 && cp -r /usr/share/locale/en\@* /tmp/ && rm -rf /usr/share/locale/* && mv /tmp/en\@* /usr/share/locale/ \
 && mkdir $APP_HOME

WORKDIR $APP_HOME
COPY ["package.json", "yarn.lock", "${APP_HOME}/"]

RUN yarn install --pure-lockfile

COPY ["mix.exs", "mix.lock", "${APP_HOME}/"]
RUN mix local.hex --force \
 && mix local.rebar --force \
 && mix deps.get

COPY config ${APP_HOME}/config
COPY lib ${APP_HOME}/lib
COPY test ${APP_HOME}/test
COPY web ${APP_HOME}/web
COPY priv ${APP_HOME}/priv
COPY rel/config.exs ${APP_HOME}/rel/
RUN mix compile

COPY webpack.config.js $APP_HOME/webpack.config.js
COPY .babelrc $APP_HOME/.babelrc
RUN mkdir -p priv/static \
 && mix assets.compile \
 && mix phoenix.digest

EXPOSE 4000

CMD ["mix", "phoenix.server"]
