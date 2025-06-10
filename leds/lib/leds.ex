defmodule Leds.Blink do
  use Application
  alias Circuits.GPIO

  @doc """
  Hello world.

  ### project title
  leds to in gpio pin 20 and 26
  then when one led is high, the other should be low
  then after third time make them high together

  open the gpio pin pin12

  """
  require Logger

  @output_pin 26
  @input_pin 20
  def start() do
    {:ok, outpin} = GPIO.open(@output_pin, :output)
    # starting pins
    spawn(fn -> blink_forever(outpin) end)

    # blink_forever(outpin)
  end

  def blink_forever(output_gpio) do
    IO.inspect("On")
    GPIO.write(output_gpio, 1)
    Process.sleep(500)

    IO.inspect("Off")
    GPIO.write(output_gpio, 0)
    Process.sleep(500)

    blink_forever(output_gpio)
  end
end
