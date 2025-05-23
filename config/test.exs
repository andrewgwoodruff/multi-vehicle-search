import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :multi_vehicle_search, MultiVehicleSearchWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ksZ26d3C66QMmOROnTkydR23LW+4+WW4xtW4QJIW5dAk9RLFEiJb1PA3t25yU2Co",
  server: false

# In test we don't send emails
config :multi_vehicle_search, MultiVehicleSearch.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
