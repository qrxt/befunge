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
    { _, coords, _, _, output } = acc

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
      |> execute({ [], { 0, 0 }, :right, :numeric, ""}) # start
  end

  def get_next_acc(acc, digit) when (digit in 0..9) do
    { stack, coords, direction, mode, output } = acc

    { [ digit | stack ], move(coords, direction), direction, mode, output }
  end

  def get_next_acc(acc, symbol) do
    { stack, coords, direction, mode, output } = acc
    { top, rest } = Stack.pop(stack)

    keep_moving = move(coords, direction)

    # todo:
    # p(put)
    # g(get)

    if mode === :ascii && symbol !== "'" do
      { [ symbol | stack ], keep_moving, direction, mode, output }
    else
      case symbol do
        ">" -> { stack, move(coords, :right), :right, mode, output }
        "v" -> { stack, move(coords, :down), :down, mode, output }
        "<" -> { stack, move(coords, :left), :left, mode, output }
        "^" -> { stack, move(coords, :up), :up, mode, output }
        "?" -> rnd_move(acc)
        "#" -> { stack, jump(coords, direction), direction, mode, output }

        "." -> { rest, keep_moving, direction, mode, output |> output_as_integer(top) }
        "," -> { rest, keep_moving, direction, mode, output |> output_as_string(top) }
        ":" -> { [ top | stack ], keep_moving, direction, mode, output }

        "_" -> if_hrz(acc)
        "|" -> if_vrt(acc)

        "+" -> binary(acc, &(&1 + &2))
        "-" -> binary(acc, &(&1 - &2))
        "*" -> binary(acc, &(&1 * &2))
        "/" -> binary(acc, &(div(&1, &2)))
        "%" -> binary(acc, &(rem(&1, &2)))
        "`" -> binary(acc, fn (first, second) ->
          cond do
            first > second -> 0
            true -> 1
          end
        end)

        "'" -> { stack, keep_moving, direction, toggle_mode(mode), output }
        "\\" -> binary(acc, &([&2, &1]))

        "$" -> { rest, keep_moving, direction, mode, output }
        "!" -> { [ invert(top) | rest ], keep_moving, direction, mode, output }
        _ -> { stack, keep_moving, direction, mode, output }
      end
    end
  end

  defp toggle_mode(mode) do
    case mode do
      :ascii -> :numeric
      :numeric -> :ascii
      _ -> :numeric
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

  defp rnd_move({ stack, coords, _, mode, output }) do
    rnd_dir = [:left, :right, :up, :down]
      |> Enum.random

    { stack, move(coords, rnd_dir), rnd_dir, mode, output }
  end

  defp output_as_integer(output, top) do
    output <> Integer.to_string(top)
  end

  defp output_as_string(output, top) do
    output <> List.to_string([top])
  end

  defp if_hrz({ stack, coords, _, mode, output }) do
    { top, rest } = Stack.pop(stack)

    case top do
      0 -> { rest, move(coords, :right), :right, mode, output }
      _ -> { rest, move(coords, :left), :left, mode, output }
    end
  end

  defp if_vrt({ stack, coords, _, mode, output }) do
    { top, rest } = Stack.pop(stack)

    case top do
      0 -> { rest, move(coords, :down), :down, mode, output }
      _ -> { rest, move(coords, :up), :up, mode, output }
    end
  end

  defp binary({ stack, coords, direction, mode, output }, op) do
    { first, without } = Stack.pop(stack)
    { second, rest } = Stack.pop(without)

    applied = [ op.(first, second) | rest ]
      |> List.flatten
    { applied, move(coords, direction), direction, mode, output }
  end

  defp invert(val) do
    case val do
      0 -> 1
      _ -> 0
    end
  end
end

"                           v" <> "\n" <>
"@,,,,,,,,,,,,'Hello World!'<"
  |> Befunge.execute
  |> IO.inspect
