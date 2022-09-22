defmodule Data.Util do
  alias GSS.Spreadsheet

  def parse_atom("nil"), do: nil
  def parse_atom(":" <> atom_name), do: String.to_atom(atom_name)

  def parse_atom_flag("nil"),
    do: {nil, nil}

  def parse_atom_flag(":" <> atom_name) do
    [atom | maybe_flag] = String.split(atom_name, "/")

    atom = parse_atom(":" <> atom)
    flag = List.first(maybe_flag)

    {atom, flag}
  end

  def parse_range(str) do
    {range, _} = String.replace(str, "-", "..") |> Code.eval_string()
    range
  end

  def parse_int(string), do: String.to_integer(string)

  def parse_float(string), do: String.to_float(string)

  def parse_number(""),
    do: 0

  def parse_number(string) do
    if String.contains?(string, "."),
      do: parse_float(string),
      else: parse_int(string)
  end

  def parse_bonus(string) do
    [from, value, type, to] = String.split(string, ",", trim: true)

    %Core.Bonus{
      from: parse_atom(from),
      value: parse_number(value),
      type: parse_atom(type),
      to: parse_atom(to)
    }
  end

  def parse_int_list(string) do
    string
    |> String.trim_leading("[")
    |> String.trim_trailing("]")
    |> String.split(",")
    |> Enum.reject(fn el -> el == "" end)
    |> Enum.map(&parse_int/1)
  end

  def parse_atom_list(string) do
    string
    |> String.trim_leading("[")
    |> String.trim_trailing("]")
    |> String.split(",")
    |> Enum.reject(fn el -> el == "" end)
    |> Enum.map(&parse_atom/1)
  end

  def read_sheet(url, sheet) do
    max_columns = 40
    max_rows_by_batch = 300

    {:ok, pid} = Spreadsheet.Supervisor.spreadsheet(url, list_name: sheet)
    {:ok, rows_count} = Spreadsheet.rows(pid)

    rows =
      Enum.flat_map(0..trunc(rows_count / max_rows_by_batch), fn i ->
        from = i * max_rows_by_batch + 1
        to = (i + 1) * max_rows_by_batch
        to = if to > rows_count, do: rows_count, else: to

        {:ok, rows} = Spreadsheet.read_rows(pid, from, to, pad_empty: true, column_to: max_columns)

        rows
      end)

    [_title | [header | rows]] = rows

    {header, rows}
  end
end
