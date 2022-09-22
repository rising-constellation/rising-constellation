defmodule RC.Blog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  alias RC.Blog.Post
  alias RC.Accounts.Account
  alias RC.Markdown

  schema "blog_comments" do
    field(:content_html, :string)
    field(:content_raw, :string)
    belongs_to(:account, Account)
    belongs_to(:post, Post)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(blog_comment, attrs) do
    blog_comment
    |> cast(attrs, [:content_raw, :account_id, :post_id])
    |> validate_required([:content_raw, :account_id, :post_id])
    |> validate_length(:content_raw, max: 1500)
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:account_id)
    |> Markdown.render_changeset(:content_raw, :content_html)
  end
end
