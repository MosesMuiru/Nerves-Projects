defmodule HelloNerves.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    delux_options = Application.get_all_env(:blinky)
    Logger.debug("Target specific options for --#{inspect(delux_options)}")

    children =
      [
        # Children for all targets
        # Starts a worker by calling: HelloNerves.Worker.start_link(arg)
        # {HelloNerves.Worker, arg},
        {Delux, delux_options ++ [initial: Delux.Effects.blink(:on, 2)]}
      ] ++ target_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloNerves.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  if Mix.target() == :host do
    defp target_children() do
      [
        # Children that only run on the host during development or test.
        # In general, prefer using `config/host.exs` for differences.
        #
        # Starts a worker by calling: Host.Worker.start_link(arg)
        # {Host.Worker, arg},
      ]
    end
  else
    defp target_children() do
      [
        # Children for all targets except host
        # Starts a worker by calling: Target.Worker.start_link(arg)
        # {Target.Worker, arg},
      ]
    end
  end
end
