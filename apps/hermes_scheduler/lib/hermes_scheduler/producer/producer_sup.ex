defmodule HScheduler.Producer.ProducerSup do
  use Supervisor

  alias HScheduler.Producer.PushProducer
  alias HScheduler.Producer.MailProducer

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, [name: __MODULE__])

  def init(:ok) do
    children = [
      :poolboy.child_spec(PushProducer, push_pool_config, []),
      :poolboy.child_spec(MailProducer, mail_pool_config, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def mail_pool_config do
    [
      {:name, {:local, MailProducer.pool_name}},
      {:worker_module, MailProducer},
      {:size, 5},
      {:max_overflow, 20},
      {:strategy, :fifo}
    ]
  end

  def push_pool_config do
    [
      {:name, {:local, PushProducer.pool_name}},
      {:worker_module, PushProducer},
      {:size, 5},
      {:max_overflow, 20},
      {:strategy, :fifo}
    ]
  end
end
