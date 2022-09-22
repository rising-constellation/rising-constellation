defmodule Mix.Tasks.UpdateConversation do
  @shortdoc "Update the `last_message_update` field of table Conversations"

  use Mix.Task

  import Ecto.Query, warn: false
  alias RC.Repo
  alias RC.Messenger.Conversation
  alias RC.Messenger.Message

  import Ecto.Query, warn: false

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    Repo.all(Conversation)
    |> Enum.each(fn conversation ->
      [last_message | _] =
        Repo.all(
          from(message in Message,
            where: message.conversation_id == ^conversation.id,
            order_by: [desc: message.inserted_at]
          )
        )

      conversation
      |> Conversation.changeset(%{last_message_update: last_message.inserted_at})
      |> Repo.update()
    end)
  end
end
