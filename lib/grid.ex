defmodule Grid do
    def into_map(list) do
      0..length(list) - 1
        |> Enum.zip(list)
        |> Enum.into(%{})
    end
  
    def from(str) do
      str
        |> String.split("\n")
        |> Enum.map(
          fn row -> row
            |> String.graphemes
            |> into_map
          end
        )
        |> into_map
    end
  
    def read_cell(grid, coords) do
      { x, y } = coords
  
      grid
        |> Access.get(y)
        |> Access.get(x)
    end

    def set_cell(grid, coords, operator) do 
      { x, y } = coords
      row = grid |> Map.get(y)

      modified = row
        |> Map.put(x, operator)

      grid
        |> Map.put(y, modified)
    end
  end