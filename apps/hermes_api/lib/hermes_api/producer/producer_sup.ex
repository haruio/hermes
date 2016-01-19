defmodule Producer.ProducerSup do
  use Supervisor

  alias Producer.PushProducer
  alias Producer.MailProducer

  def start_link(args \\ []) do
    Supervisor.start_link __MODULE__, args, [name: __MODULE__]
  end

  def init(args \\ []) do
    children = [
      :poolboy.child_spec(PushProducer, push_producer_config, []),
      :poolboy.child_spec(MailProducer, mail_producer_config, [])
    ]

    supervise children, strategy: :one_for_one
  end

  def push_producer_config do
    [
      {:name, {:local, PushProducer}},
      {:worker_module, PushProducer},
      {:strategy, :fifo},
      {:size, 10},
      {:max_overflow, 100}
    ]
  end

  def mail_producer_config do
    [
      {:name, {:local, MailProducer}},
      {:worker_module, MailProducer},
      {:size, 10},
      {:max_overflow, 100}
    ]
  end
 end
