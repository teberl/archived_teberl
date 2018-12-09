use Mix.Config

port = String.to_integer(System.get_env("PORT") || "8080")

config :myapp, MyApp.Endpoint,
  http: [port: port],
  url: [host: System.get_env("HOSTNAME"), port: port],
  root: ".",
  secret_key_base: System.get_env("SECRET_KEY_BASE")
