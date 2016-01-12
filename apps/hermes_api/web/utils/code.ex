defmodule Code.PushStatus do
  @approved "APR"
  @publishing "PUING"
  @published "PUED"
  @canceled "CAED"
  @reserved "RVED"

  def cd_approved, do: @approved
  def cd_publishing, do: @publishing
  def cd_published, do: @published
  def cd_canceled, do: @canceled
  def cd_reserved, do: @reserved
end
