defmodule HScheduler.Model.Service do
  use Ecto.Model

  @primary_key {:service_id, :string, []}
  schema "service" do
    field :service_nm, :string
    field :gcm_api_key, :string
    field :apns_key, :string
    field :apns_cert, :string
    field :apns_dev_key, :string
    field :apns_dev_cert, :string
    field :rest_token, :string
    field :android_token, :string
    field :ios_token, :string
    field :create_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :update_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :create_user, :integer
    field :update_user, :integer
  end

  @required_fields ~w(service_id service_nm gcm_api_key apns_key apns_cert rest_token android_token ios_token apns_dev_cert apns_dev_key)
  @optional_fields ~w(create_dt update_dt create_user update_user)

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
    alias HScheduler.Model.Service

    def select_one_by_service_id(service_id) do
      service_id
      |> by_service_id
      |> Repo.one
    end

    def select_one_by_rest_token([rest_token]), do: select_one_by_rest_token(rest_token)
    def select_one_by_rest_token(rest_token) do
      rest_token
      |> by_rest_token
      |> Repo.one
    end

    def by_service_id(service_id) do
      from s in Service,
      where: s.service_id == ^service_id
    end

    def by_rest_token(rest_token) do
      from s in Service,
      where: s.rest_token == ^rest_token
    end
  end

end


