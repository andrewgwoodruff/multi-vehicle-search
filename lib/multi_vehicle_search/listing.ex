defmodule MultiVehicleSearch.Listing do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :id, :string
    field :length, :integer
    field :width, :integer
    field :location_id, :string
    field :price_in_cents, :integer
  end
end
