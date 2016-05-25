defmodule HApi.MailTemplateController do
  use HApi.Web, :controller

  plug ProperCase.Plug.SnakeCaseParams

  alias HApi.{Repo, Template}

  def create_template(conn, %{"title" => title, "html" => html}) do
    service_id = conn.assigns[:service]
    |> Map.get(:service_id)

    now = Ecto.DateTime.utc

    ## Query
    Template.changeset(%Template{} ,%{title: title, html: html, service_id: service_id})
    |> Ecto.Changeset.put_change(:create_dt, now)
    |> Ecto.Changeset.put_change(:update_dt, now)
    |> Repo.insert

    send_json conn, %{}
  end

  def delete_template(conn, %{"template_seq" => template_seq}) do
    result = with {:ok, template} <- select_my_template(conn.assigns[:service].service_id, template_seq),
                  {:ok, _deleted} <- Repo.delete(template),
                  do: {:ok, "Deleted"}

    send_json conn, result
  end

  def update_template(conn, %{"template_seq" => template_seq} = params) do
    changes = Map.take(params, ["title", "html"])

    result = with {:ok, template} <- select_my_template(conn.assigns[:service].service_id, template_seq),
                  {:ok, _updated} <- Template.changeset(template, changes) |> Ecto.Changeset.put_change(:update_dt, Ecto.DateTime.utc) |> Repo.update,
                  do: {:ok, "updated"}

    send_json conn, result
  end

  def get_template_list(conn, params) do
    data = from(t in Template, where: [], order_by: t.create_dt, select: %{title: t.title, create_dt: t.create_dt, update_dt: t.update_dt})
    |> Repo.paginate(page: Map.get(params, "pageNum", 1), page_size: Map.get(params, "pageSize", 10))
    |> DTOUtil.to_dto

    send_json conn, data
  end

  def get_template(conn, %{"template_seq" =>  template_seq}) do
    result = case select_my_template(conn.assigns[:service].service_id, template_seq) do
               {:ok, template} -> DTOUtil.to_dto(template)
               {:error, _reason}=error -> error
             end

    send_json conn, result
  end

  defp select_my_template(service_id, template_seq) do
    case from(t in Template, where: ^[service_id: service_id, template_seq: template_seq]) |> Repo.one do
      nil -> {:error, "Not found"}
      template -> {:ok, template}
    end
  end

end
