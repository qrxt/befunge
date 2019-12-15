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