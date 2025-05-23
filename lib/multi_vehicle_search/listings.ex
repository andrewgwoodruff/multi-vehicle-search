defmodule MultiVehicleSearch.Listings do
  use GenServer

  alias MultiVehicleSearch.Combinatorics
  alias MultiVehicleSearch.Listing

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_locations(vehicle_requests) do
    GenServer.call(__MODULE__, {:get_locations, vehicle_requests})
  end

  def init(_) do
    listings = load_listings()
    {:ok, %{listings: listings}}
  end

  def handle_call({:get_locations, vehicle_requests}, _from, %{listings: listings}) do
    locations = search_locations(vehicle_requests, listings)
    {:reply, locations, %{listings: listings}}
  end

  defp load_listings do
    # "listings.json"
    # |> File.read!()
    # |> Jason.decode!(keys: :atoms)
    # |> Enum.map(fn listing ->
    #   struct(Listing, listing)
    # end)

    []
  end

  defp search_locations(vehicles, listings) do
    sorted_vehicles =
      vehicles
      |> Enum.reduce([], fn vehicle, acc ->
        quantity = vehicle["quantity"]

        if quantity > 1 do
          Enum.reduce(1..quantity, acc, fn _, inner_acc -> [vehicle] ++ inner_acc end)
        else
          [vehicle] ++ acc
        end
      end)
      |> Enum.sort(fn vehicle1, vehicle2 -> vehicle1["length"] <= vehicle2["length"] end)

    listings
    |> Enum.group_by(& &1.location_id)
    |> Enum.reduce([], fn {location_id, location_listings}, acc ->
      case can_use_location?(location_id, location_listings, sorted_vehicles) do
        nil -> acc
        false -> acc
        {true, cheapest_combination_of_listings} -> [cheapest_combination_of_listings] ++ acc
      end
    end)
  end

  defp can_use_location?(location_id, listings, sorted_vehicles) do
    num_vehicles = Enum.count(sorted_vehicles)

    Enum.map(1..num_vehicles, fn num ->
      listings
      |> Combinatorics.combinations(num)
      |> Enum.reduce([], fn listing_combination, acc ->
        if can_use_combination?(listing_combination, sorted_vehicles) do
          [listing_combination] ++ acc
        else
          acc
        end
      end)
      |> case do
        [] ->
          false

        listing_combinations ->
          cheapest_combination_of_listings =
            listing_combinations
            |> Enum.map(fn listing_combination ->
              Enum.reduce(
                listing_combination,
                %{location_id: location_id, total_price_in_cents: 0, listing_ids: []},
                fn %{id: listing_id, price_in_cents: price_in_cents},
                   %{
                     location_id: location_id,
                     total_price_in_cents: total_price_in_cents,
                     listing_ids: listing_ids
                   } ->
                  %{
                    location_id: location_id,
                    total_price_in_cents: total_price_in_cents + price_in_cents,
                    listing_ids: [listing_id] ++ listing_ids
                  }
                end
              )
            end)
            |> Enum.sort(fn %{total_price_in_cents: total_price_in_cents1},
                            %{total_price_in_cents: total_price_in_cents2} ->
              total_price_in_cents1 <= total_price_in_cents2
            end)
            |> Enum.at(0)

          {true, cheapest_combination_of_listings}
      end
    end)
    |> Enum.reject(fn element -> element == false end)
    |> Enum.sort(fn {true, location_combo1}, {true, location_combo2} ->
      location_combo1.total_price_in_cents <= location_combo2.total_price_in_cents
    end)
    |> Enum.at(0)
  end

  defp can_use_combination?(listing_combination, sorted_vehicles) do
    listing_combination
    |> Enum.sort(fn listing1, listing2 ->
      listing1.width <= listing2.width
    end)
    |> Enum.reduce_while({false, sorted_vehicles}, fn
      %{width: _width} = _listing, {_, []} ->
        {:halt, true}

      %{length: length_available, width: width_available}, {_, vehicles} ->
        vehicles
        |> Enum.reduce_while(
          {length_available, width_available, width_available, vehicles},
          fn _vehicle,
             {length_still_available, width_still_available, listing_width, vehicles_acc} ->
            case another_listing_is_needed?(
                   length_still_available,
                   width_still_available,
                   listing_width,
                   vehicles_acc
                 ) do
              {true, return_vehicles_acc} ->
                {:halt, {false, return_vehicles_acc}}

              {false, []} ->
                {:halt, true}
            end
          end
        )
        |> case do
          true -> {:halt, true}
          {false, vehicles} -> {:cont, {false, vehicles}}
        end
    end)
    |> case do
      true -> true
      {false, _} -> false
    end
  end

  defp another_listing_is_needed?(
         _length_still_available,
         _width_still_available,
         _listing_width,
         []
       ) do
    {false, []}
  end

  defp another_listing_is_needed?(
         length_still_available,
         width_still_available,
         listing_width,
         [%{"length" => length} | tail] = vehicles
       ) do
    cond do
      width_still_available >= 10 and length <= length_still_available ->
        another_listing_is_needed?(
          length_still_available,
          width_still_available - 10,
          listing_width,
          tail
        )

      length_still_available - length >= length ->
        another_listing_is_needed?(
          length_still_available - length,
          listing_width,
          listing_width,
          tail
        )

      true ->
        {true, vehicles}
    end
  end
end
