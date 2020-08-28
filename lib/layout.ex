defmodule Layout do
  @moduledoc """
  Describes a keyboard layout.
  """

  alias __MODULE__.{Key, LED}

  @type t :: %__MODULE__{
          keys: [Key.t()],
          leds: [LED.t()],
          leds_by_keys: %{Key.id() => LED.t()},
          keys_by_leds: %{LED.id() => Key.t()}
        }
  defstruct [:keys, :leds, :leds_by_keys, :keys_by_leds]

  @spec new(keys :: [Key.t()], leds :: [LED.t()]) :: t
  def new(keys, leds \\ []) do
    leds_map = Map.new(leds, &{&1.id, &1})

    leds_by_keys =
      keys
      |> Enum.filter(& &1.led)
      |> Map.new(&{&1.id, Map.fetch!(leds_map, &1.led)})

    keys_by_leds =
      keys
      |> Enum.filter(& &1.led)
      |> Map.new(&{&1.led, &1})

    %__MODULE__{
      keys: keys,
      leds: leds,
      leds_by_keys: leds_by_keys,
      keys_by_leds: keys_by_leds
    }
  end

  @spec keys(layout :: t) :: [Key.t()]
  def keys(layout), do: layout.keys

  @spec leds(layout :: t) :: [LED.t()]
  def leds(layout), do: layout.leds

  @spec led_for_key(layout :: t, Key.id()) :: LED.t() | nil
  def led_for_key(%__MODULE__{} = layout, key_id) when is_atom(key_id),
    do: Map.get(layout.leds_by_keys, key_id)

  @spec key_for_led(layout :: t, LED.id()) :: Key.t() | nil
  def key_for_led(%__MODULE__{} = layout, led_id) when is_atom(led_id),
    do: Map.get(layout.keys_by_leds, led_id)

  @spec get_and_build_leds() :: [LED.t()]
  def get_and_build_leds() do
    Application.get_env(:xebow, :leds, [])
    |> Enum.map(fn %{id: id, x: x, y: y} ->
      LED.new(id, x, y)
    end)
  end

  @spec get_and_build_keys() :: [Key.t()]
  def get_and_build_keys() do
    Application.get_env(:xebow, :keys, [])
    |> Enum.map(fn
      %{id: id, x: x, y: y, opts: opts} ->
        Key.new(id, x, y, opts)

      %{id: id, x: x, y: y} ->
        Key.new(id, x, y)
    end)
  end
end
