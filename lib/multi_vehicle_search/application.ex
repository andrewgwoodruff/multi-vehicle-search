defmodule MultiVehicleSearch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MultiVehicleSearchWeb.Telemetry,
      MultiVehicleSearch.Listings,
      {DNSCluster,
       query: Application.get_env(:multi_vehicle_search, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MultiVehicleSearch.PubSub},
      # Start a worker by calling: MultiVehicleSearch.Worker.start_link(arg)
      # {MultiVehicleSearch.Worker, arg},
      # Start to serve requests, typically the last entry
      MultiVehicleSearchWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MultiVehicleSearch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MultiVehicleSearchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
