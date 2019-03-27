# Don't fear the release
___Releases with Distillery 2.0 and Docker___

## Contents

1. **[OTP Release using distillery](https://gist.github.com/teberl/f09976e24937e3a1ba066fe63ffd1637#otp-release-using-distillery)**
    * Create a new phoenix project
    * Building the first release
    * Run your release
    * Move the release anywhere
    * Performing upgrades
2. **[Building releases with docker](https://gist.github.com/teberl/f09976e24937e3a1ba066fe63ffd1637#building-a-release-inside-docker)**
    * Multi-stage docker builds
    * The `Dockerfile`
    * Use `config_providers`
3. **[Automating the build process](https://gist.github.com/teberl/f09976e24937e3a1ba066fe63ffd1637#automating-the-build-process)**
     * Create a `Makefile`
     * Using of docker-compose
4. **[Ressources](https://gist.github.com/teberl/f09976e24937e3a1ba066fe63ffd1637#ressources)**

## OTP Release using distillery

### Create a new phoenix project

```bash
➜ mix phx.new --no-ecto my_app
```

#### Add distillery

`mix.exs`

```elixir
...

defp deps do
    [
     ...,   
     {:distillery, "~> 2.0"}
    ]
  end
```

#### Update `config/prod.exs`

* `System.get_env(varname)`  _Returns the value of the given environment variable_
* `server` configures the endpoint to boot the Cowboy application http endpoint on start
* `root` configures the application root for serving static files
* `version` ensures that the asset cache will be busted on versioned application upgrades (hot-upgrades)

```elixir
port = System.get_env("PORT") || 4000
host = System.get_env("HOST") || "localhost"

config :phoenix_distillery, MyAppWeb.Endpoint,
  http: [port: port],
  url: [host: host, port: port],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:phoenix_distillery, :vsn)
```

> `endpoint.ex` You should set gzip to true if you are running phx.digest when deploying your static files in production.

### Building the first release

#### Fetching deps

* fetch production dependencies from [hex](https://hex.pm)
* initialize distillery which creates\
`rel/config.exs`
* in addition to an empty directory\
`rel/plugins/`

```zsh
➜ mix deps.get --only prod
➜ mix release.init
```

#### Compile elixir and assets

* `mix phx.digest` compress and tag your assets for proper caching
* `mix release env=prod` generate a release for a production environment
* _hint:_ combined mix tasks with `MIX_ENV=prod mix do phx.digest, release env=prod`

```zsh
➜ MIX_ENV=prod mix compile
➜ cd assets && webpack --mode production && cd ..
➜ MIX_ENV=prod mix phx.digest
➜ MIX_ENV=prod mix release --env=prod
```

> If you are inside an umbrella application and you got an error regarding _Jason_\
> check `config/config.exs` and ensure the line\
> `config :phoenix, :json_library, Jason`\
> exists

### Run the release

```zsh
➜ _build/prod/rel/my_app/bin/my_app start
➜ _build/prod/rel/my_app/bin/my_app stop
➜ _build/prod/rel/my_app/bin/my_app foreground
```

### Move the release anywhere

* `cp _build/prod/rel/my_app/releases/0.0.1/my_app.tar.gz deployment_target/`\
Move the release anywhere by copying the release tarball
* `cd deployment_target/ && tar xvf my_app.tar.gz`\
Extract the tarball at in the target location
* `./bin/my_app start`
* `./bin/my_app stop`

### Performing upgrades

#### Bump the version in `mix.exs` and add new features

```elixir
def project do
   [
    version: "0.2.0",
    ...
   ]
end
```

#### Create a new **--upgrad** release

* `MIX_ENV=prod mix release --env=prod --upgrade`\
tells Distillery to build an upgrade from the previously built releases in the output directory 
* If the upgrade build is not failing a new tarball is created\
`_build/prod/rel/phoenix_distillery/releases/0.2.0/my_app.tar.gz`
* This tarball can deployed into an existing release, for example in the previous used deployment target

```zsh
➜ MIX_ENV=prod mix compile
➜ cd assets && webpack --mode production && cd ..
➜ MIX_ENV=prod mix phx.digest
➜ MIX_ENV=prod mix release --env=prod --upgrade
```

#### Deploy the new release to the target and run the upgrade

```zsh
➜ cp _build/prod/rel/phoenix_distillery/releases/0.2.0/my_app.tar.gz  deployment_destination/releases/0.2.0/
➜ ./deployment_target/bin/my_app upgrade
```

> Don't forget to create a new release directory\
`mkdir deployment_target/release/0.2.0`
> Depending on your changes, you may have to reload your browser to see the changes

## Building a release inside docker

### Multi-stage docker builds

> With **multi-stage builds**, you use multiple `FROM` statements in your Dockerfile. Each `FROM` instruction can use a different base, and each of them begins a new stage of the build. You can selectively **copy artifacts from one stage to another**, leaving behind everything you don’t want in the final image.

#### Add a `.dockerignore`

```
_build/
deps/
.git/
.gitignore
Dockerfile
Makefile
README*
test/
priv/static/
```

#### Add a `Dockerfile`

```Dockerfile
#StageOne: Build Container
FROM elixir:1.7.4-alpine AS builder

# The following are build arguments used to change variable parts of the image.
ARG ALPINE_VERSION=3.8
ARG APP_NAME
ARG APP_VSN
ARG MIX_ENV=prod
ARG SKIP_PHOENIX=false
ARG PHOENIX_SUBDIR=.

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
    APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV}

WORKDIR /opt/app

# Installs build tools
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    nodejs \
    npm \
    git \
    build-base && \
    mix local.rebar --force && \
    mix local.hex --force

# Copy our app source code into the build container
COPY . .

RUN mix do deps.get, deps.compile, compile

# Digest assets if we have a phoenix app
RUN if [ ! "$SKIP_PHOENIX" = "true" ]; then \
    cd ${PHOENIX_SUBDIR}/assets && \
    npm ci && \
    npm run deploy && \
    cd .. && \
    mix phx.digest; \
    fi

# Create a release, copy and extract the tarball into a build folder
RUN \
    mkdir -p /opt/built && \
    mix release --verbose && \
    cp _build/${MIX_ENV}/rel/${APP_NAME}/releases/${APP_VSN}/${APP_NAME}.tar.gz /opt/built && \
    cd /opt/built && \
    tar -xzf ${APP_NAME}.tar.gz && \
    rm ${APP_NAME}.tar.gz

# StageTwo: Runtime Container
FROM alpine:${ALPINE_VERSION}

ARG APP_NAME

RUN apk update && \
    apk add --no-cache \
    bash \
    openssl-dev

# OS_VARS will be set in our makefile
ENV REPLACE_OS_VARS=true \
    APP_NAME=${APP_NAME}

WORKDIR /opt/app

# Copy the release from StageOne
COPY --from=builder /opt/built .

CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} foreground
```

### Use config-providers

Configuration providers for loading and persisting runtime configuration during boot.  

> *Compiletime vs. Runtime variables*
> 
> * `http: [port: System.get_env("PORT")]`  
> Here you would need to provide the PORT environment variable at build time which is when that code would be executed.
> * `{:system, "PORT"}`  
> This isn't some magic code to retrieve an environment variable, it is a setting that tells Phoenix to retrieve the port number from the PORT environment variable at runtime

#### Create/Update `rel/config.exs`

```elixir
release :myapp do
  # snip..
  set config_providers: [
    {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/etc/config.exs"]}
  ]

  # Overlays allow you to modify the contents of the release, you may add/symlink files, create directories, and generate files based on templates.
  set overlays: [
    {:copy, "rel/config/config.exs", "etc/config.exs"}
  ]
end
```

#### Create/Update the referenced config file `rel/config/config.exs`

> Use Compile time variables from our docker.env to replace with runtime variables from the original phoenix `my_app/config/config.exs` 

```elixir
use Mix.Config

config :myapp, MyApp.Repo,
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_PASS"),
  database: System.get_env("DATABASE_NAME"),
  hostname: System.get_env("DATABASE_HOST"),
  pool_size: 15

port = String.to_integer(System.get_env("PORT") || "8080")
config :myapp, MyApp.Endpoint,
  http: [port: port],
  url: [host: System.get_env("HOSTNAME"), port: port],
  root: ".",
  secret_key_base: System.get_env("SECRET_KEY_BASE")
```

## Automating the build process

> To help automate building images, it is recommended to use a *Makefile* or shell script.\
> Run Makefiles with the `make` command in your project directory

### Create a `Makefile`

```Makefile
.PHONY: help

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

help:
    @echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
    @perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
    docker build --build-arg APP_NAME=$(APP_NAME) \
        --build-arg APP_VSN=$(APP_VSN) \
        -t $(APP_NAME):$(APP_VSN)-$(BUILD) \
        -t $(APP_NAME):latest .

run: ## Run the app in Docker
    docker run --env-file config/docker.env \
        --expose 4000 -p 4000:4000 \
        --rm -it $(APP_NAME):latest
```

> If make reports an error mentioning multiple target patterns
> Ensure that you are using tabs and not spaces in the makefile

#### Run the build command

`➜ make build`

### Using of docker-compose

#### Create a `config/docker.env`

> This variables will be exported as system env variables inside our running docker container

```
HOSTNAME=localhost
SECRET_KEY_BASE="u1QXlca4XEZKb1o3HL/aUlznI1qstCNAQ6yme/lFbFIs0Iqiq/annZ+Ty8JyUCDc"
DATABASE_HOST=db
DATABASE_USER=postgres
DATABASE_PASS=postgres
DATABASE_NAME=myapp_db
PORT=4000
LANG=en_US.UTF-8
REPLACE_OS_VARS=true
ERLANG_COOKIE=myapp
```

#### `docker-compose up`

`docker-compose.yml`

```yml
version: '3.5'

services:
  web:
    image: "myapp:latest"
    ports:
      - "80:4000" # In our .env file above, we chose port 4000
    env_file:
      - config/docker.env
```

#### `docker-swarm`

* `docker swarm init --advertise-addr <ip address of droplet> --listen-addr <ip address of droplet>`
* `docker stack deploy -c docker-compose.yml myapp`

```yml
version: '3.5'

networks: 
  webnet:
    driver: overlay
    attachable: true # enables running custom commands in the container

services:
  web:
    image: "myapp:latest"

    ports:
      - "80:4000"
    env_file:
      - config/docker.env # exports our system env variables
    networks:
      - webnet
```

## Ressources

### Link List
[Distillery - github](https://github.com/bitwalker/distillery/)  
[Distillery - Phoenix Walkthrough](https://hexdocs.pm/distillery/guides/phoenix_walkthrough.html)  
[elixir-forum - Compiletime/Runtime variables](https://elixirforum.com/t/what-is-the-difference-between-using-system-port-and-system-get-env-port-in-deployment/1975)  
[Docker multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/)  
[Distillery - Working with Docker](https://hexdocs.pm/distillery/guides/working_with_docker.html)  
[Slides](https://docs.google.com/presentation/d/1wx4nmsqn_itfUdxienDa6bIeo8tF0xT4EuQsKnRy8Ug/edit?usp=sharing)
