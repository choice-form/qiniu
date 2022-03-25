defmodule Qiniu.Fop.Zip do
  @moduledoc """
  zip multiple !!!public files
  https://developer.qiniu.com/dora/1667/mkzip
  """
  alias Qiniu.{HTTP, PutPolicy, Uploader}

  def multi_files(save_bucket, save_key, exist_url_in_save_bucket, resource_keys, build_url_func \\ nil, opts \\ [])
      when is_list(resource_keys) and length(resource_keys) > 0 do
    saveas = Base.url_encode64("#{save_bucket}:#{save_key}")
    res_keys = build_zip_resource(resource_keys, build_url_func)

    body = %{
             bucket: save_bucket,
             key: exist_url_in_save_bucket,
             fops: "mkzip/2" <> res_keys <> "|saveas/#{saveas}",
             pipeline: opts[:pipeline],
             notifyURL: opts[:notify_url]
           }
           |> URI.encode_query

    HTTP.auth_post("#{Qiniu.config[:api_host]}/pfop/", body)
  end

  # if you don't set saveas, you won't get the zip file, it'll create a zip file named by hash string.
  def massive_files(index_bucket, index_key, save_bucket, save_key, opts \\ []) do
    saveas = Base.url_encode64("#{save_bucket}:#{save_key}")

    body = %{
             bucket: index_bucket,
             key: index_key,
             fops: "mkzip/4|saveas/#{saveas}",
             pipeline: opts[:pipeline],
             notifyURL: opts[:notify_url]
           }
           |> URI.encode_query

    HTTP.auth_post("#{Qiniu.config[:api_host]}/pfop/", body)
  end

  def massive_files(index_bucket, index_key, save_bucket, save_key, resource_keys, build_url_func, opts \\ [])
      when is_list(resource_keys) and length(resource_keys) > 0 do
    index_file_buf = build_zip_resource(resource_keys, build_url_func)

    index_policy = PutPolicy.build(index_bucket, index_key)
    with {:ok, _} <- Uploader.upload_buffer(index_policy, index_file_buf, content_type: "text/plain") do
      saveas = Base.url_encode64("#{save_bucket}:#{save_key}")

      body =
        %{
          bucket: index_bucket,
          key: index_key,
          fops: "mkzip/4|saveas/#{saveas}",
          pipeline: opts[:pipeline],
          notifyURL: opts[:notify_url]
        }
        |> URI.encode_query

      HTTP.auth_post("#{Qiniu.config[:api_host]}/pfop/", body)
    end
  end

  @doc """
   iex> Qiniu.Fop.Zip.build_zip_resource(["/pub/a.xtx", ["/pub/b.mp4", "/pub/b_test.mp4"]])
  """
  def build_zip_resource([first_key | keys], build_url_func) do
    url = concat_with_encoded_key(build_url_func, first_key)

    Enum.reduce(
      keys,
      url,
      fn (key, acc) ->
        "#{concat_with_encoded_key(build_url_func, key)}/" <> acc
      end
    )
  end

  defp concat_with_encoded_key(build_url_func, [key, alias]) do
    concat_with_encoded_key(build_url_func, key) <> "/alias/#{Base.url_encode64(alias)}"
  end

  defp concat_with_encoded_key(nil, key) do
    "url/#{Base.url_encode64(key)}"
  end

  defp concat_with_encoded_key(build_url_func, key) do
    "url/#{Base.url_encode64(build_url_func.(key))}"
  end
end
