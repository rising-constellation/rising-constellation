defmodule RC.PlayerReports do
  import Ecto.Query, warn: false

  alias RC.Repo
  alias RC.Instances.PlayerReport

  @doc """
  Creates a player_report.
  """
  def create(attrs \\ %{}) do
    %PlayerReport{}
    |> PlayerReport.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets all player_reports
  """
  def by_registration(registration_id) do
    query =
      from(pr in PlayerReport,
        where: pr.registration_id == ^registration_id and pr.is_hidden == false,
        order_by: [desc: :inserted_at]
      )

    # TODO: make pagination work
    # Repo.paginate(query)

    Repo.all(query)
  end

  def hide(registration_id, report_id) do
    Repo.get_by!(PlayerReport, registration_id: registration_id, id: report_id)
    |> Ecto.Changeset.change(is_hidden: true)
    |> Repo.update()
  end
end
