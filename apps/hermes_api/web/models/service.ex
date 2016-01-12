defmodule HApi.Service do
  use HApi.Web, :model

  @primary_key {:service_id, :string, []}
  @derive {Phoenix.Param, key: :service_id}
  schema "service" do
    field :service_nm, :string
    field :gcm_api_key, :string
    field :apns_key, :string
    field :apns_cert, :string
    field :rest_token, :string
    field :android_token, :string
    field :ios_token, :string
    field :create_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :update_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :create_user, :integer
    field :update_user, :integer

    # timestamps
  end

  @required_fields ~w(service_id service_nm gcm_api_key apns_key apns_cert rest_token android_token ios_token)
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
end


defmodule HApi.Service.Query do
  import Ecto.Query
  alias HApi.Repo


  def select_one_by_service_id(service_id) do
    service_id
    |> by_service_id
    |> Repo.one
  end

  def by_service_id(service_id) do
    from s in HApi.Service,
    where: s.service_id == ^service_id
  end
end
