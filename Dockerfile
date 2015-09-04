FROM alpine:3.2
MAINTAINER Jonas Thiel <jonas@thiel.io>

RUN echo 'http://dl-4.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories

RUN apk --update add ncurses-libs erlang wget curl erlang-crypto build-base libstdc++\
    erlang-syntax-tools erlang-inets erlang-ssl erlang-public-key erlang-xmerl\
    erlang-asn1 erlang-sasl erlang-erl-interface erlang-dev nodejs git python\
    && rm -rf /var/cache/apk/*

ENV ELIXIR_VERSION 1.0.5

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

ADD . $APP_HOME

#RUN mix deps.get
RUN npm install
#RUN mix phoenix.server

#EXPOSE 4000

CMD ["/bin/sh"]
