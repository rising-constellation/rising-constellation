defmodule Portal.Blog.PostView do
  use Portal, :view
  alias Portal.Blog.PostView

  def render("index.json", %{posts: posts}) do
    render_many(posts, PostView, "post_index.json")
  end

  def render("show.json", %{post: post}) do
    render_one(post, PostView, "post.json")
  end

  def render("show_update.json", %{post: post}) do
    render_one(post, PostView, "post_update.json")
  end

  def render("post.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      slug: post.slug,
      picture: post.picture,
      summary_html: post.summary_html,
      content_html: post.content_html,
      language: post.language
    }
  end

  def render("post_update.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      slug: post.slug,
      picture: post.picture,
      summary_html: post.summary_html,
      summary_raw: post.summary_raw,
      content_raw: post.content_raw,
      content_html: post.content_html,
      language: post.language
    }
  end

  def render("post_index.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      slug: post.slug,
      picture: post.picture,
      summary_html: post.summary_html,
      language: post.language
    }
  end
end
