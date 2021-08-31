defmodule NflRushing.PlayerStats.ConversionHelpers do
  @moduledoc """
    Contains testable helper functions for pre-processing Player data.
    This module does not deal with Ecto.

    The priv/repo/seeds.exs makes use of these functions, and also loads
    the resulting data into Ecto.
  """

  def int_to_str(number_string) when is_binary(number_string) do
    if String.match?(number_string, ~r/^-?\d+T?$/) do
      number_string
    else
      raise "Expected an integer as a string, but received: #{inspect number_string}"
    end
  end

  def int_to_str(number) when is_integer(number), do: Integer.to_string(number)

  def str_to_int(number) when is_integer(number), do: number

  def str_to_int(number) when is_binary(number) do
    number = String.replace(number, ",", "")

    case Integer.parse(number) do
      {integer, remainder} ->
        if remainder == "" do
          integer
        else
          raise "Failed integer conversion. Input string=#{inspect(number)}, Result integer: #{
                  inspect(integer)
                }, remainder: #{inspect(remainder)}"
        end

      error_msg ->
        raise "Failed integer conversion. Input string=#{inspect(number)}.  Error: #{
                inspect(error_msg)
              }"
    end
  end

  def int_to_float(number) when is_float(number), do: number
  def int_to_float(number) when is_integer(number), do: number / 1
end
