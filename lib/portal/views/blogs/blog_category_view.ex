defmodule Portal.Blog.CategoryView do
  use Portal, :view
  alias Portal.Blog.CategoryView

  def render("index.json", %{categories: categories}) do
    render_many(categories, CategoryView, "category.json")
  end

  def render("show.json", %{category: category}) do
    render_one(category, CategoryView, "category.json")
  end

  def render("category.json", %{category: category}) do
    %{id: category.id, name: category.name, slug: category.slug, language: category.language}
  end
end
