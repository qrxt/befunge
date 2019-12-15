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
  
    def read_cell(command, coords) do
      { x, y } = coords
  
      command
        |> Access.get(y)
        |> Access.get(x)
    end

    def set_cell(command, coords, operator) do 
      { x, y } = coords
      row = command |> Map.get(y)

      modified = row
        |> Map.put(x, operator)

      command
        |> Map.put(y, modified)
    end
  end