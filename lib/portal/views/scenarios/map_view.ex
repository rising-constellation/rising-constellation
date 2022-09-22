defmodule Portal.MapView do
  use Portal, :view
  alias Portal.MapView

  def render("index.json", %{maps: maps}) do
    render_many(maps, MapView, "map_partial.json")
  end

  def render("show.json", %{map: map}) do
    render_one(map, MapView, "map_full.json")
  end

  def render("edges.json", %{edges: edges}) do
    edges
  end

  def render("map_full.json", %{map: map}) do
    %{
      id: map.id,
      game_data: map.game_data,
      game_metadata: map.game_metadata,
      is_official: map.is_official,
      thumbnail: map.thumbnail,
      likes: map.likes,
      dislikes: map.dislikes,
      favorites: map.favorites
    }
  end

  def render("map_partial.json", %{map: map}) do
    %{
      id: map.id,
      game_metadata: map.game_metadata,
      is_official: map.is_official,
      thumbnail: map.thumbnail,
      likes: map.likes,
      dislikes: map.dislikes,
      favorites: map.favorites
    }
  end
end
