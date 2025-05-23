defmodule MultiVehicleSearch.ListingsTest do
  use MultiVehicleSearch.DataCase, async: true

  alias MultiVehicleSearch.Listings

  describe "get_locations/1" do
    test "returns locations" do
      vehicles = [
        %{"length" => 10, "quantity" => 1},
        %{"length" => 20, "quantity" => 2},
        %{"length" => 25, "quantity" => 16}
      ]

      IO.inspect(Listings.get_locations(vehicles), label: "FINAL RESULT", limit: :infinity)
    end
  end
end
