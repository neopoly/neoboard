# Neoboard

Steps to start the Dashboard application

**WARNING:** This application is in a very early *ALPHA* state. Everything may change while I'm exploring Elixir and React.

## Requirements

### Install Elixir

Detailed instructions to install Elixir are available at: http://elixir-lang.org/install.html

### Install Javascript tools

This project also needs NodeJS for static assets compilation:

* Install [NodeJS](https://nodejs.org/download/)
* Install [yarn](https://yarnpkg.com/en/docs/install)

## Start an instance

Configure the widgets you want to use in `config/widgets.exs`:

    $ vim config/widgets.exs

Install all Elixir dependencies:

    $ mix deps.get

Install all NPM dependencies:

    $ yarn install

Now you can startup a server instance:

    $ mix phx.server

Now you can visit `localhost:4000` from your browser.

## Production system

For a productive system you should pre-compile the used assets. A custom mix
tasks is provided to instrument webpack's build process:

    $ mix assets.precompile

Also you should generate hashed versions of the static files by invoking
Phoenix "digest" task:

    $ mix phx.digest

## Release and run via distillery

    $ node_modules/webpack/bin/webpack.js -p --progress
    $ export NEOBOARD_SECRET_BASE_KEY=<GENERATED>
    $ export NEOBOARD_COOKIE=<GENERATED_COOKIE>
    $ export NEOBOARD_PORT=4000
    $ MIX_ENV=prod mix do phx.digest, release --no-tar

    $ rel/neoboard/bin/neoboard foreground

## LICENSE

Please have a look at `LICENSE.txt` for further information about the license this project is published under.
