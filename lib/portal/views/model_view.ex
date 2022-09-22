defmodule Portal.ModelView do
  use Portal, :view
  alias Portal.ModelView

  def render("index.json", %{models: models}) do
    render_many(models, ModelView, "model.json")
  end

  def render("show.json", %{model: model}) do
    render_one(model, ModelView, "model.json")
  end

  def render("model.json", %{model: model}) do
    %{
      id: model.id,
      name: model.name,
      description: model.description,
      game_data: model.game_data
    }
  end
end
