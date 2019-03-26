defmodule PhxClientWeb.LayoutView do
  use PhxClientWeb, :view

  def get_year() do
    {year, _} = DateTime.utc_now() |> Date.year_of_era()
    year
  end
end
