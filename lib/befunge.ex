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
    0
  end

  def pop(stack) do
    [ first | rest ] = stack
    { first, rest }
  end
end

defmodule Befunge do
  def execute(command, acc) do
    { stack, coords, _, output } = acc

    current = command
      |> Grid.read_cell(coords)

    if current === "@" do
      stack
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
      |> execute({ [], { 0, 0 }, :right, ""})
  end

  def get_next_acc(acc, digit) when (digit in 0..9) do
    { stack, coords, direction, output } = acc
    { [ digit | stack ], move(coords, direction), direction, output }
  end

  def get_next_acc(acc, symbol) do
    { stack, coords, direction, output } = acc

    case symbol do
      ">" -> { stack, move(coords, :right), :right, output }
      "v" -> { stack, move(coords, :down), :down, output }
      "<" -> { stack, move(coords, :left), :left, output }
      "^" -> { stack, move(coords, :up), :up, output }
      "+" -> { add(stack), move(coords, direction), direction, output }
      _ -> { stack, move(coords, direction), direction, output }
    end
  end

  def move({ x, y }, direction) do
    case direction do
      :right -> { x + 1, y }
      :down -> { x, y + 1 }
      :left -> { x - 1, y }
      :up -> { x, y - 1 }
    end
  end

  def add(stack) do
    { first, rest } = stack
      |> Stack.pop

    { second, next_stack }  = rest
      |> Stack.pop

    [ first + second | next_stack ]
  end
end

">   1v" <> "\n" <>
"@  32<"
  |> Befunge.execute
  |> IO.inspect
