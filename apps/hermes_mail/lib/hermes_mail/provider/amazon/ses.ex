defmodule HMail.Provider.Amazon.SES do
  alias HMail.Provider.Amazon.Certification

  def send_email(%Certification{}=cert, %Email{}=email) do
    {cert, email}
  end

  def send_email(sender, %Email{}=email) when is_pid(sender) do
    {sender, email}
  end
end
