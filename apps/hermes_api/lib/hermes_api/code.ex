defmodule Code.PushStatus do
  @approved "APR" # 대기중
  @publishing "PUING" # 발송중
  @published "PUED" # 발송 완료
  @canceled "CAED" # 취소완료
  @canceling "CAING" # 취소중
  @reserved "RVED" # 예약

  def cd_approved, do: @approved
  def cd_publishing, do: @publishing
  def cd_published, do: @published
  def cd_canceled, do: @canceled
  def cd_reserved, do: @reserved
  def cd_canceling, do: @canceling
end
