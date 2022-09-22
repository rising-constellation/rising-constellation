defmodule RC.Repo.Migrations.FixTextTypes do
  use Ecto.Migration

  def change do
    alter table(:account_tokens) do
      modify(:candidate_email, :text)
    end

    alter table(:blog_categories) do
      modify(:name, :text)
      modify(:slug, :text)
    end

    alter table(:blog_posts) do
      modify(:title, :text)
      modify(:slug, :text)
      modify(:picture, :text)
      modify(:content_raw, :text)
      modify(:content_html, :text)
      modify(:summary_raw, :text)
      modify(:summary_html, :text)
    end

    alter table(:blog_comments) do
      modify(:content_raw, :text)
      modify(:content_html, :text)
    end

    alter table(:conversations) do
      modify(:name, :text)
    end

    alter table(:folders) do
      modify(:name, :text)
      modify(:description, :text)
    end

    alter table(:groups) do
      modify(:name, :text)
    end

    alter table(:instances) do
      modify(:name, :text)
      modify(:description, :text)
    end

    alter table(:messages) do
      modify(:content_raw, :text)
      modify(:content_html, :text)
    end

    alter table(:profiles) do
      modify(:name, :text)
      modify(:avatar, :text)
      modify(:full_name, :text)
      modify(:description, :text)
      modify(:long_description, :text)
    end

    alter table(:scenarios) do
      modify(:thumbnail, :text, null: true)
    end

    alter table(:store_customers) do
      modify(:email, :text, null: false)
      modify(:stripe_id, :text, null: false)
    end

    alter table(:store_inventory) do
      modify(:item, :text, null: false)
      modify(:type, :text, null: false)
    end
  end
end
