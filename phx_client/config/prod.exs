use Mix.Config

port = System.get_env("PORT") || 4000
ssl_port = System.get_env("SSL_PORT") || 4001
host = System.get_env("HOST") || "localhost"

config :phx_client, PhxClientWeb.Endpoint,
  # force_ssl: [hsts: true],
  http: [:inet6, port: port],
  https: [
    :inet6,
    port: ssl_port,
    cipher_suite: :strong,
    keyfile: System.get_env("TEBERL_SSL_KEY_PATH"),
    certfile: System.get_env("TEBERL_SSL_CERT_PATH")
  ],
  url: [host: host, port: ssl_port],
  check_origin: ["//localhost", "//teberl.de"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:phoenix_distillery, :vsn)

# Do not print debug messages in production
config :logger, level: :info

# Finally import the config/prod.secret.exs which should be versioned
# separately.
import_config "prod.secret.exs"
