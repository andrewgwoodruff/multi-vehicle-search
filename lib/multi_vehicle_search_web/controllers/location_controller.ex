defmodule MultiVehicleSearchWeb.LocationController do
  use MultiVehicleSearchWeb, :controller

  alias MultiVehicleSearch.Listings

  def search_locations(conn, %{"_json" => vehicle_requests}) do
    locations = Listings.get_locations(vehicle_requests)

    json(conn, locations)
  end
end
