defmodule Portal.Date do
  def format(date, mode) do
    month =
      case date.month do
        1 -> "jan."
        2 -> "fév."
        3 -> "mars"
        4 -> "avril"
        5 -> "mai"
        6 -> "juin"
        7 -> "juil."
        8 -> "août"
        9 -> "sept."
        10 -> "oct."
        11 -> "nov."
        12 -> "déc."
      end

    case mode do
      :date ->
        "#{date.day} #{month} #{date.year}"

      :datetime ->
        hour =
          date.hour
          |> Integer.to_string()
          |> String.pad_leading(2, "0")

        minute =
          date.minute
          |> Integer.to_string()
          |> String.pad_leading(2, "0")

        "#{date.day} #{month} #{date.year}, #{hour}:#{minute}"
    end
  end
end
