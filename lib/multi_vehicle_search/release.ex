defmodule MultiVehicleSearch.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """

  def migrate do
    IO.inspect("Skipping migrations!")
  end
end
