defmodule Mix.Tasks.UpdateData do
  use Mix.Task

  @content_path "./lib/data/game/content"
  @content_ext ".ex"

  # read-data-sheets@rising-constellation.iam.gserviceaccount.com

  @shortdoc "Update data by reading csv from Google Spreadsheet."
  def run(module_name) do
    Mix.Task.run("app.start")

    modules =
      if length(module_name) == 1,
        do: Enum.filter(Data.Querier.modules(), fn m -> m.string == List.first(module_name) end),
        else: Data.Querier.modules()

    Enum.each(modules, fn %{module: module} ->
      # Fetch all different sheets and get results
      Enum.each(module.specs, fn spec ->
        case spec.sources do
          {url, sheet} ->
            IO.puts("Updating #{spec.content_name}")

            # Read data from googlesheet and extract headers and data
            {header, data} = Data.Util.read_sheet(url, sheet)

            # Use the corresponding transformer to take a list into elixir code
            content =
              module.csv_to_struct(header, data, spec.metadata)
              |> Kernel.inspect(limit: :infinity, charlists: :as_lists)

            source =
              Code.format_string!("""
              # credo:disable-for-this-file Credo.Check.Readability.LargeNumbers

              defmodule #{spec.module} do
                def data do
                  #{content}
                end
              end
              """)

            # Save source to the corresponding location
            output = "#{@content_path}/#{spec.content_name}#{@content_ext}"
            File.write(output, source)

          nil ->
            IO.puts("Module #{spec.content_name} has no source")
        end
      end)
    end)
  end
end
