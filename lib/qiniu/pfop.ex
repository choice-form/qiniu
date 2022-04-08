defmodule Qiniu.Pfop do
  alias Qiniu.HTTP
  alias Qiniu.FopPolicy

  @doc """
  Execute a pfop action.

  [Document](https://developer.qiniu.com/dora/1291/persistent-data-processing-pfop)

  ## Example

      fop_policy = %Qiniu.FopPolicy{bucket: "bucket", key: "key", fops: "mkzip/4|saveas/saveas}
      Qiniu.Pfop.pfop(fop_policy)
      # =>
      %HTTPoison.Response{body: %{"persistentId" => "id"}}
  """
  def pfop(%FopPolicy{} = policy) do
    url = "#{Qiniu.config()[:api_host]}/pfop/"

    HTTP.auth_post(url, FopPolicy.encoded_json(policy))
  end

  @doc """
  Query the status of data processing.

  [Document](https://developer.qiniu.com/dora/1294/persistent-processing-status-query-prefop)
  """
  def prefop(persistent_id) do
    HTTP.get("#{Qiniu.config()[:api_host]}/status/get/prefop?id=#{persistent_id}")
  end
end
