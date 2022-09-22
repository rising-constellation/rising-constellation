defmodule Portal.Blog.CommentView do
  use Portal, :view
  alias Portal.Blog.CommentView

  def render("index.json", %{comments: comments}) do
    render_many(comments, CommentView, "comment.json")
  end

  def render("show.json", %{comment: comment}) do
    render_one(comment, CommentView, "comment.json")
  end

  def render("show_update.json", %{comment: comment}) do
    render_one(comment, CommentView, "comment_update.json")
  end

  def render("comment.json", %{comment: comment}) do
    %{id: comment.id, content_html: comment.content_html}
  end

  def render("comment_update.json", %{comment: comment}) do
    %{id: comment.id, content_raw: comment.content_raw, content_html: comment.content_html}
  end
end
