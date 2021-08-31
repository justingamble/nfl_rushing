defmodule NflRushing.PlayerLoadTest do
  use ExUnit.Case, async: true
  alias NflRushing.PlayerStats.ConversionHelpers
#  import PlayerStats.ConversionHelpers, only: [int_to_str: 1, str_to_int: 1, int_to_float: 1]

  describe "str_to_int() function" do
    test "success: returns an integer when input is already an integer" do
      assert ConversionHelpers.str_to_int(5) == 5
    end

    test "success: returns an integer when input string is a positive integer" do
      assert ConversionHelpers.str_to_int("5") == 5
    end

    test "success: returns an integer when input string is a negative integer" do
      assert ConversionHelpers.str_to_int("-5") == -5
    end

    test "exception: raises an exception when input string is a float" do
      assert_raise RuntimeError, fn -> ConversionHelpers.str_to_int("3.2") end
    end

    test "exception: raises an exception when input string is not-a-number" do
      assert_raise RuntimeError, fn -> ConversionHelpers.str_to_int("NAN") end
    end
  end

  describe "int_to_str() function" do
    test "success: returns a string when input is a single character, a positive integer" do
      assert ConversionHelpers.int_to_str("5") == "5"
    end

    test "success: returns a string when input is multiple characters, all positive integers" do
      assert ConversionHelpers.int_to_str("54321") == "54321"
    end

    test "success: returns a string when input is a negative integer string" do
      assert ConversionHelpers.int_to_str("-5") == "-5"
    end

    test "success: returns a string when input is a positive integer with a letter T" do
      assert ConversionHelpers.int_to_str("5T") == "5T"
    end

    test "success: returns a string when input is a negative integer with a letter T" do
      assert ConversionHelpers.int_to_str("-5T") == "-5T"
    end

    test "success: returns a string when input is an integer" do
      assert ConversionHelpers.int_to_str(5) == "5"
    end

    test "success: returns a string when input is a negative integer" do
      assert ConversionHelpers.int_to_str(-5) == "-5"
    end

    test "exception: raises an exception when input string contains a float" do
      assert_raise RuntimeError, fn -> ConversionHelpers.int_to_str("5.2") end
    end

    test "exception: raises an exception when input string contains an integer and non-T letter" do
      assert_raise RuntimeError, fn -> ConversionHelpers.int_to_str("5F") end
    end

    test "exception: raises an exception when input string has 2 minus signs in front of integer" do
      assert_raise RuntimeError, fn -> ConversionHelpers.int_to_str("--5") end
    end

    test "exception: raises an exception when input is a float" do
      assert_raise FunctionClauseError, fn -> ConversionHelpers.int_to_str(5.2) end
    end
  end

end
