defmodule HApi.Mail do
  use HApi.Web, :model

  @primary_key {:mail_id, :string, []}
  @derive {Phoenix.Param, key: :mail_id}
  schema "mail" do
    field :service_id, :string
    field :type_cd, :string
    field :from, :string
    field :mail_condition, :string
    field :mail_status, :string
    field :publish_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :publish_start_dt, Ecto.DateTime
    field :publish_end_dt, Ecto.DateTime
    field :body, :string
    field :title, :string
    field :template_html, :integer
    field :template_data, :string
    field :request_cnt, :integer
    field :provider_cd, :string
    field :create_user, :integer, default: 1
    field :update_user, :integer, default: 1
    field :create_dt, Ecto.DateTime, default: Ecto.DateTime.utc
    field :update_dt, Ecto.DateTime, default: Ecto.DateTime.utc
  end

  @required_fields ~w(service_id mail_condition publish_dt mail_id)
  @optional_fields ~w(mail_status from publish_start_dt publish_end_dt body title template_html template_data request_cnt provider_cd create_user create_dt update_user update_dt type_cd)

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
