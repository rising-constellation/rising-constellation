defmodule RC.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Filtrex.Type.Config

  alias RC.Markdown
  alias RC.Blog.Category
  alias RC.Blog.TitleSlug

  schema "blog_posts" do
    field(:title, :string)
    field(:slug, :string)
    field(:content_html, :string)
    field(:content_raw, :string)
    field(:language, :string)
    field(:picture, :string)
    field(:summary_html, :string)
    field(:summary_raw, :string)
    belongs_to(:account, RC.Accounts.Account)
    belongs_to(:category, Category)

    timestamps(type: :utc_datetime_usec)
  end

  def filter_options do
    defconfig do
      text(:language)
      number(:account_id)
      number(:category_id)
    end
  end

  @doc false
  def changeset(blog_post, attrs) do
    blog_post
    |> cast(attrs, [:title, :picture, :content_raw, :summary_raw, :language, :account_id, :category_id])
    |> validate_required([:title, :picture, :content_raw, :summary_raw, :language, :account_id, :category_id])
    |> validate_length(:title, max: 120)
    |> validate_length(:picture, max: 120)
    |> validate_length(:summary_raw, max: 1500)
    |> validate_length(:language, max: 2)
    |> TitleSlug.maybe_generate_slug()
    |> Markdown.render_changeset(:content_raw, :content_html)
    |> Markdown.render_changeset(:summary_raw, :summary_html)
  end
end

defmodule RC.Blog.TitleSlug do
  use EctoAutoslugField.Slug, from: :title, to: :slug, always_change: true
end
