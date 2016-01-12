defmodule Util.KeyGenerator do
  use Timex
  @base_alpha_length 62
  @base_alpha [
    "ETczP5tj68NhoMwxpmuZSv0OFgY3VnJi1beIsBHLRKyqlfkWd4aD7UGCArQ9X2",
    "HFK3h1otaQlRzbwOvnqUxIfJ6yecZGVgLT4k9DSiMPCjANdXmY52Wrs0Ep8B7u",
    "h15Nlg6KFfuAyH3BtzTq0awnrsLDPdYImSxp7c2RX89oWGeEJQVjbvkUOZ4CMi",
    "XmTiCxsHUIWD49Ln6ak8G7eObhpgquBREtjMF1ASydo0YQ2fz3PvlV5NJZrKwc",
    "fnqSdkITMmLC5UQOFhYaNB2GEJoeDWiZxb8Xzrts3VARw06cgK4ypu7jPHl19v",
    "mnVQ7hAKHUT0iOklD3LJ5Cgb4GtxpZXc6r2Iaw9o8EMBqfyFWjzevSdsRYP1uN",
    "h15Nlg6KFfuAyH3BtzTq0awnrsLDPdYImSxp7c2RX89oWGeEJQVjbvkUOZ4CMi",
    "ETczP5tj68NhoMwxpmuZSv0OFgY3VnJi1beIsBHLRKyqlfkWd4aD7UGCArQ9X2",
    "XmTiCxsHUIWD49Ln6ak8G7eObhpgquBREtjMF1ASydo0YQ2fz3PvlV5NJZrKwc",
    "HFK3h1otaQlRzbwOvnqUxIfJ6yecZGVgLT4k9DSiMPCjANdXmY52Wrs0Ep8B7u",
    "XmTiCxsHUIWD49Ln6ak8G7eObhpgquBREtjMF1ASydo0YQ2fz3PvlV5NJZrKwc"
  ]

  def gen_timebased_key do
    Date.universal
    |> Date.to_timestamp
    |> Tuple.to_list
    |> Enum.map_join "-", &(int_to_random_62_string(&1))
  end

  def int_to_random_62_string(val) do
    r_int_to_random_62_string(val, @base_alpha, "")
  end

  defp r_int_to_random_62_string(0, _, key), do: key

  defp r_int_to_random_62_string(val, [h | t], key) do
    r_int_to_random_62_string(div(val, @base_alpha_length), t, key <> String.at(h, rem(val, @base_alpha_length)))
  end


  def int_to_random_62_string_fixed(val) do
    r_int_to_random_62_string_fixed(val, @base_alpha, "")
  end

  defp r_int_to_random_62_string_fixed(_, [], key), do: key
  defp r_int_to_random_62_string_fixed(val, [h | t], key) do
    r_int_to_random_62_string_fixed(div(val, @base_alpha_length), t, key <> String.at(h, rem(val, @base_alpha_length)))
  end

end
