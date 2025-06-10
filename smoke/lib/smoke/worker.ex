defmodule Smoke.Worker do
  @doc """
    vol -> pin 2
  ground -> pin 3

  analog -> 20
  digital -> 19
    
  """

  @analog_pin 19
  @digital_pin 20
  use GenServer

  require Logger
  alias Circuits.GPIO

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, gpio} = GPIO.open(@analog_pin, :input)

    GPIO.set_interrupts(gpio, :both)
    IO.inspect(label: "set successfully")
    {:ok, gpio}
  end

  def handle_info({:circuits_gpio, @analog_pin, _timestamp, value}, gpio) do
    Logger.info("Listening for smoke events")
    IO.puts("Listening for smoke events")

    case value do
      0 -> IO.puts("🚨 Gas detected!")
      1 -> IO.puts("✅ Gas cleared!")
    end

    Process.sleep(500)

    {:noreply, gpio}
  end

  @spec listen() :: any()
  def listen() do
    #    {:ok, analog_gpio} = GPIO.open(@analog_pin, :input)
    # spawn(fn -> sense_smoke(analog_gpio) end)

    {:ok, digital_gpio} = GPIO.open(@digital_pin, :input)

    IO.inspect(digital_gpio, label: "digital pin")
    spawn(fn -> sense_smoke(digital_gpio) end)
  end

  def sense_smoke(gpio) do
    IO.inspect(gpio, label: "sense_smoke at-- ")
    GPIO.set_interrupts(gpio, :both)
    listen_server()
  end

  def listen_server() do
    receive do
      {:circuits_gpio, p, timestamp, 1} ->
        IO.inspect(label: "at #{timestamp} smoke was high, by this pin --> #{p}")

      {:circuits_gpio, p, timestamp, 0} ->
        # code
        IO.inspect(label: "at #{timestamp} smoke was low by this pin --> #{p}")
    end

    Process.sleep(500)
    listen_server()
  end
end
