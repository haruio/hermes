defmodule HScheduler.Model.PushOption do
  use Ecto.Model

  schema "push_option" do
    field :push_id, :string
    field :push_type, :string
    field :option, :string
  end

  @required_fields ~w(push_id push_type option)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  defmodule Query do
    alias HScheduler.Repo

    def select(query) do
      from(options in HScheduler.Model.PushOption,
           where: ^query,
           select: %{ push_type: options.push_type, option: options.option })
      |> Repo.all
    end
  end
end
