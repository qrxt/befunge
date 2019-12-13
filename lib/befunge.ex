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
    {x, y} = coords

    command
      |> Access.get(y)
      |> Access.get(x)
  end
end

defmodule Stack do
  def pop([]) do
    { 0, [] }
  end

  def pop(stack) do
    [ first | rest ] = stack
    { first, rest }
  end

  def push(stack, item) do
    [ item | stack ]
  end
end

defmodule Befunge do
  def execute(command, acc) do
    { _, coords, _, output } = acc

    current = command
      |> Grid.read_cell(coords)

    if current === "@" do
      output
    else
      parsed = current
        |> Integer.parse

      next_acc = case parsed do
        :error -> get_next_acc(acc, current)
        { digit, _ } -> get_next_acc(acc, digit)
      end

      command
        |> execute(next_acc)
    end
  end

  def execute(command) do
    command
      |> Grid.from
      |> execute({ [], { 0, 0 }, :right, ""}) # start
  end

  def get_next_acc(acc, digit) when (digit in 0..9) do
    { stack, coords, direction, output } = acc

    { [ digit | stack ], move(coords, direction), direction, output }
  end

  def get_next_acc(acc, symbol) do
    { stack, coords, direction, output } = acc
    { top, rest } = Stack.pop(stack)

    case symbol do
      ">" -> { stack, move(coords, :right), :right, output }
      "v" -> { stack, move(coords, :down), :down, output }
      "<" -> { stack, move(coords, :left), :left, output }
      "^" -> { stack, move(coords, :up), :up, output }
      "." -> { rest, move(coords, direction), direction, output |> output_as_integer(top) }
      "," -> { rest, move(coords, direction), direction, output |> output_as_string(top) }
      ":" -> { [ top | stack ], move(coords, direction), direction, output }
      "_" -> if_hrz(acc)
      "|" -> if_vrt(acc)
      "#" -> { stack, jump(coords, direction), direction, output }
      _ -> { stack, move(coords, direction), direction, output }
    end
  end

  defp move({ x, y }, direction) do
    case direction do
      :right -> { x + 1, y }
      :down -> { x, y + 1 }
      :left -> { x - 1, y }
      :up -> { x, y - 1 }
    end
  end

  defp jump({ x, y }, direction) do
    case direction do
      :right -> { x + 2, y }
      :down -> { x, y + 2 }
      :left -> { x - 2, y }
      :up -> { x, y - 2 }
    end
  end

  defp output_as_integer(output, top) do
    output <> Integer.to_string(top)
  end

  defp output_as_string(output, top) do
    output <> List.to_string([top])
  end

  defp if_hrz({ stack, coords, _, output }) do
    { top, rest } = Stack.pop(stack)

    case top do
      0 -> { rest, move(coords, :right), :right, output }
      _ -> { rest, move(coords, :left), :left, output }
    end
  end

  defp if_vrt({ stack, coords, _, output }) do
    { top, rest } = Stack.pop(stack)

    case top do
      0 -> { rest, move(coords, :down), :down, output }
      _ -> { rest, move(coords, :up), :up, output }
    end
  end
end

">#@1.@" <> "\n" <>
""
  |> Befunge.execute
  |> IO.inspect
