defmodule Qiniu.FopPolicy do
  defstruct bucket: nil, key: nil, fops: nil, notify_url: nil, force: nil, pipeline: nil

  @type t :: %__MODULE__{
          bucket: binary,
          key: binary,
          fops: binary,
          notify_url: binary | nil,
          force: boolean,
          pipeline: binary | nil
        }

  def build(bucket, key, fops, opts \\ []) when is_list(fops) or is_map(fops) do
    %__MODULE__{
      bucket: bucket,
      key: key,
      fops: build_fops(fops),
      notify_url: opts[:notify_url],
      force: opts[:force],
      pipeline: opts[:pipeline]
    }
  end

  @doc """
  Build fop string.

  Support pipeline by pass the fop map list.

  ## Example

      Qiniu.FopPolicy.build_fops(%{"avthumb" => "mp4", "s" => "640x360", "saveas" => "bucket1:test.mp4"})
      # =>
      "avthumb/mp4/s/640x360|saveas/YnVja2V0MTp0ZXN0Lm1wNA=="

      Qiniu.FopPolicy.build_fops([%{"avthumb" => "mp4", "s" => "640x360", "saveas" => "bucket1:test.mp4"}, %{"avthumb" => "mp4", "s" => "1024x768", saveas: "bucket1:test.mp4"}])
      # =>
      "avthumb/mp4/s/640x360|saveas/YnVja2V0MTp0ZXN0Lm1wNA==|avthumb/mp4/s/1027x768|saveas/YnVja2V0MTp0ZXN0Lm1wNA=="

  ## Attention

    The key must be string in the map.

  """
  def build_fops(fops) when is_map(fops) do
    build_fops([fops])
  end

  def build_fops(fops) when is_list(fops) do
    fops
    |> Enum.flat_map(fn fop ->
      {saveas, others} = Map.split(fop, ["saveas", "deleteAfterDays"])
      [others, saveas]
    end)
    |> Enum.reject(&(map_size(&1) == 0))
    |> Enum.map(&build_fop/1)
    |> Enum.join("|")
  end

  defp build_fop(fop) do
    fop
    |> Enum.map(fn {key, val} -> "#{key}/#{val}" end)
    |> Enum.join("/")
  end

  def encoded_json(%__MODULE__{} = policy) do
    policy
    |> Map.from_struct()
    |> Enum.reject(fn
      {:__struct__, _} -> true
      {_, nil} -> true
      _ -> false
    end)
    |> Enum.map(fn
      # NOTE 特殊处理回调 URL 参数
      {:notify_url, url} -> {"notifyURL", url}
      {k, v} -> {Qiniu.Utils.camelize(k), v}
    end)
    |> Map.new()
    |> URI.encode_query()
  end
end
