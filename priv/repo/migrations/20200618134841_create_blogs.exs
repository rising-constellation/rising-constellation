defmodule RC.Repo.Migrations.CreateBlogs do
  use Ecto.Migration

  def change do
    # RC.Blog.Category tables
    create table(:blog_categories) do
      add(:name, :string)
      add(:slug, :string)
      add(:language, :string, size: 2)

      timestamps()
    end

    # RC.Blog.Post tables
    create table(:blog_posts) do
      add(:title, :string)
      add(:slug, :string)
      add(:picture, :string)
      add(:content_raw, :string)
      add(:content_html, :string)
      add(:summary_raw, :string)
      add(:summary_html, :string)
      add(:language, :string, size: 2)
      add(:account_id, references(:accounts, on_delete: :nothing))
      add(:category_id, references(:blog_categories, on_delete: :nothing))

      timestamps()
    end

    create(index(:blog_posts, [:account_id]))
    create(index(:blog_posts, [:category_id]))

    # RC.Blog.Comment tables
    create table(:blog_comments) do
      add(:content_raw, :string)
      add(:content_html, :string)
      add(:account_id, references(:accounts, on_delete: :nothing))
      add(:post_id, references(:blog_posts, on_delete: :nothing))

      timestamps()
    end

    create(index(:blog_comments, [:account_id]))
    create(index(:blog_comments, [:post_id]))
  end
end
