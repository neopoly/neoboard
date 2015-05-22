# Neoboard

Steps to start the Dashboard application

**WARNING:** This application is in a very early *ALPHA* state. Everything may change while I'm exploring Elixir and React.

## Requirements

### Install Elixir

Detailed instructions to install Elixir are available at: http://elixir-lang.org/install.html

### Install NodeJS

This project also needs NodeJS for static assets compilation. Find installation instructions at: https://nodejs.org/download/

## Start an instance

Configure the widgets by create a configuration file at `config/widgets.exs`. You can use `config/widgets.exs.sample` as your template:

    $ cp config/widgets.exs.sample config/widgets.exs
    $ vim config/widgets.exs

Install all Elixir dependencies:

    $ mix deps.get

Install all NPM dependencies:

    $ npm install

Now you can startup a server instance:

    $ mix phoenix.server

Now you can visit `localhost:4000` from your browser.

## Production system

For a productive system you should pre-compile the used assets. A custom mix 
tasks is provided to instrument webpack's build process:

    $ mix assets.precompile

Also you should generate hashed versions of the static files by invoking 
Phoenix "digest" task:

    $ mix phoenix.digest
