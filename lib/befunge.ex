defmodule Befunge do
  def execute(command) do
    command
      |> Grid.from
      |> execute({ [], { 0, 0 }, :right, :numeric, ""}) # start
  end

  defp execute(command, { stack, coords, direction, mode, output }) do
    acc = { stack, coords, direction, mode, output }

    current = command
      |> Grid.read_cell(coords)

    case { current, mode } do
      { "@", :numeric } -> output
      { "p", :numeric } -> put(command, acc)
      { _, _ } -> execute(command, acc, current)
    end
  end

  defp execute(command, acc, current) do
    parsed = current
      |> Integer.parse

    next_acc = case parsed do
      :error -> get_next_acc(acc, current)
      { digit, _ } -> get_next_acc(acc, digit)
    end

    command
      |> execute(next_acc)
  end

  defp put(command, { stack, coords, direction, mode, output }) do
    { x, rest } = Stack.pop(stack)
    { y, rest } = Stack.pop(rest)
    { operator, rest } = Stack.pop(rest)

    next_acc = { rest, move(coords, direction), direction, mode, output }

    command |> Grid.set_cell({x, y}, operator) |> execute(next_acc)
  end

  defp get_next_acc(acc, digit) when (digit in 0..9) do
    { stack, coords, direction, mode, output } = acc

    { [ digit | stack ], move(coords, direction), direction, mode, output }
  end

  defp get_next_acc({ stack, coords, direction, :ascii, output }, symbol) when symbol !== "'" do
    { [ symbol | stack ], move(coords, direction), direction, :ascii, output }
  end

  defp get_next_acc(acc, symbol) do
    { stack, coords, direction, mode, output } = acc
    { top, rest } = Stack.pop(stack)

    keep_moving = move(coords, direction)

    # todo:
    # p(put)
    # g(get)

    case symbol do
      # Start moving right
      ">" -> { stack, move(coords, :right), :right, mode, output }
      # Start moving down
      "v" -> { stack, move(coords, :down), :down, mode, output }
      # Start moving left
      "<" -> { stack, move(coords, :left), :left, mode, output }
      # Start moving top
      "^" -> { stack, move(coords, :up), :up, mode, output }
      # Start moving up
      "?" -> rnd_move(acc)
      # Skip next cell
      "#" -> { stack, jump(coords, direction), direction, mode, output }

      # Pop value and output as an integer followed by a space
      "." -> { rest, keep_moving, direction, mode, output |> output_as_integer(top) }
      # Pop value and output as ASCII character
      "," -> { rest, keep_moving, direction, mode, output |> output_as_string(top) }

      # Pop a value; move right if value=0, left otherwise
      "_" -> if_hrz(acc)
      # Pop a value; move down if value=0, up otherwise
      "|" -> if_vrt(acc)

      # Pop a and b, then push a+b
      "+" -> binary(acc, &(&1 + &2))
      # Pop a and b, then push a-b
      "-" -> binary(acc, &(&1 - &2))
      # Pop a and b, then push a*b
      "*" -> binary(acc, &(&1 * &2))
      # Pop a and b, then push div(a, b)
      "/" -> binary(acc, &(div(&1, &2)))
      # Pop a and b, then push rem(a, b)
      "%" -> binary(acc, &(rem(&1, &2)))
      # Pop a and b, then push 1 if b>a, otherwise zero
      "`" -> binary(acc, fn (first, second) ->
        cond do
          first > second -> 0
          true -> 1
        end
      end)

      # Toggle string mode
      "'" -> { stack, keep_moving, direction, toggle_mode(mode), output }
      # Swap two values on top of the stack
      "\\" -> binary(acc, &([&2, &1]))

      # Duplicate value on top of the stack
      ":" -> { [ top | stack ], keep_moving, direction, mode, output }
      # Discard value on top of the stack
      "$" -> { rest, keep_moving, direction, mode, output }
      # Invert value on top of the stack (if the value is zero, push 1; otherwise, push zero.)
      "!" -> { [ invert(top) | rest ], keep_moving, direction, mode, output }
      # Just keep moving
      _ -> { stack, keep_moving, direction, mode, output }
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

"'v'09p1. @  >@" <> "\n" <>
"         >3.^ "
  |> Befunge.execute
  |> IO.inspect
