defmodule Qiniu.Host do
  @moduledoc """
  根据区域返回对应的地址

  存储区域列表, https://developer.qiniu.com/kodo/1671/region-endpoint-fq
  """
  @region_ids ["z0", "cn-east-2", "z1", "z2", "na0", "as0"]

  def upload_host("z0"), do: "https://upload.qiniup.com"

  def upload_host(region) when region in @region_ids,
    do: "https://upload-#{region}.qiniup.com"

  def rs_host(region) when region in @region_ids do
    "https://rs-#{region}.qiniuapi.com"
  end

  def rsf_host(region) when region in @region_ids do
    "https://rsf-#{region}.qiniuapi.com"
  end

  def io_host("z0"), do: "https://iovip.qiniuio.com"

  def io_host(region) when region in @region_ids,
    do: "https://iovip-#{region}.qiniuio.com"

  def up_host("z0"), do: "https://up.qiniup.com"

  def up_host(region) when region in @region_ids,
    do: "https://up-#{region}.qiniup.com"

  # NOTE Pfop 使用单一确认 host
  def pfop_api_host, do: "http://api.qiniu.com"
  def pfop_api_host(_), do: "http://api.qiniu.com"
end
