defmodule RC.Markdown do
  def render_inline(md) do
    Earmark.as_html!(md)
    |> HtmlSanitizeEx.markdown_html()
  end

  def render_changeset(changeset, field_to_format, field_to_set) do
    if changeset.valid? and Map.has_key?(changeset.changes, field_to_format) do
      Ecto.Changeset.put_change(changeset, field_to_set, render_inline(changeset.changes[field_to_format]))
    else
      changeset
    end
  end
end
