defmodule RC.Blog.Category do
  use Ecto.Schema
  import Ecto.Changeset
  import Filtrex.Type.Config

  alias RC.Blog.NameSlug

  schema "blog_categories" do
    field(:name, :string)
    field(:slug, :string)
    field(:language, :string)

    timestamps(type: :utc_datetime_usec)
  end

  def filter_options do
    defconfig do
      text(:language)
    end
  end

  @doc false
  def changeset(blog_category, attrs) do
    blog_category
    |> cast(attrs, [:name, :language])
    |> validate_required([:name, :language])
    |> validate_length(:name, max: 120)
    |> validate_length(:language, max: 2)
    |> NameSlug.maybe_generate_slug()
  end
end

defmodule RC.Blog.NameSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug, always_change: true
end
