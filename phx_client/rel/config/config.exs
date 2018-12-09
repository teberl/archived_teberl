use Mix.Config

port = String.to_integer(System.get_env("PORT") || "8080")
ssl_port = String.to_integer(System.get_env("SSL_PORT") || "443")

config :phx_client, PhxClientWeb.Endpoint,
  url: [host: System.get_env("HOSTNAME"), port: ssl_port],
  http: [port: port],
  https: [
    :inet6,
    port: ssl_port,
    cipher_suite: :strong,
    keyfile: System.get_env("TEBERL_SSL_KEY_PATH"),
    certfile: System.get_env("TEBERL_SSL_CERT_PATH")
  ],
  root: ".",
  secret_key_base: System.get_env("SECRET_KEY_BASE")
