defmodule HApi.MailController do
  use HApi.Web, :controller

  plug ProperCase.Plug.SnakeCaseParams

  alias HApi.{Repo, Mail}
  alias Util.KeyGenerator

  def send_mail(conn, params) do
    send_mail({conn.assigns[:service].service_id, params})

    send_json conn, %{}
  end

  ## send template
  defp send_mail({service_id, %{"template_id" => _template_id}=mail}) do
    now = Ecto.DateTime.utc

    mail = mail
    |> Map.put("service_id", service_id)
    |> Map.put("mail_id", create_mail_id(service_id))
    |> Map.put("type_cd", "T")
    |> Map.put_new("publish_dt", now)

    Mail.changeset(%Mail{}, mail)
    |> Ecto.Changeset.put_change(:create_dt, now)
    |> Ecto.Changeset.put_change(:update_dt, now)
    |> Repo.insert
  end

  ## send plain text
  defp send_mail({service_id, %{"body" => _body}=mail}) do
    now = Ecto.DateTime.utc

    mail = mail
    |> Map.put("service_id", service_id)
    |> Map.put("mail_id", create_mail_id(service_id))
    |> Map.put("type_cd", "P")
    |> Map.put_new("publish_dt", now)

    Mail.changeset(%Mail{}, mail)
    |> Ecto.Changeset.put_change(:create_dt, now)
    |> Ecto.Changeset.put_change(:update_dt, now)
    |> Repo.insert
  end


  def cancel_mail(conn, param) do
    send_json conn, %{}
  end

  def get_mail_list(conn, param) do
    send_json conn, %{}
  end

  def get_mail(conn, %{"mail_id" => mail_id}=params) do
    # result = case select_my_mail(conn.assigns[:service].service_id, template_seq) do
    #            {:ok, template} -> DTOUtil.to_dto(template)
    #            {:error, _reason}=error -> error
    #          end

    result = %{}
    send_json conn, result
  end

  def create_mail_id(service_id) do
    :random.seed :os.timestamp
    [ service_id, "m", KeyGenerator.gen_timebased_key, Enum.take_random(?a..?z, 5) ]
    |> Enum.join "-"
  end

  def select_my_mail(service_id, mail_id) do
    case from(m in Mail, where: ^[service_id: service_id, mail_id: mail_id]) |> Repo.one do
      nil -> {:error, "Not found"}
      mail -> {:ok, mail}
    end
  end
end
