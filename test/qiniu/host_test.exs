defmodule Qiniu.HostTest do
  use ExUnit.Case, async: true

  alias Qiniu.Host

  @region_ids ["z0", "cn-east-2", "z1", "z2", "na0", "as0"]

  @z0_hosts %{
    upload_host: "https://upload.qiniup.com",
    up_host: "https://up.qiniup.com",
    rs_host: "https://rs-z0.qiniuapi.com",
    rsf_host: "https://rsf-z0.qiniuapi.com",
    pfop_api_host: "http://api.qiniu.com"
  }
  @hosts @region_ids
         |> Enum.reject(&(&1 == "z0"))
         |> Map.new(fn region ->
           hosts = %{
             upload_host: "https://upload-#{region}.qiniup.com",
             up_host: "https://up-#{region}.qiniup.com",
             rs_host: "https://rs-#{region}.qiniuapi.com",
             rsf_host: "https://rsf-#{region}.qiniuapi.com",
             pfop_api_host: "http://api.qiniu.com"
           }

           {region, hosts}
         end)

  @all_hosts Map.merge(%{"z0" => @z0_hosts}, @hosts)

  test "success" do
    for region <- @region_ids, {function, host} <- @all_hosts[region] do
      assert apply(Host, function, [region]) == host
    end
  end

  test "pfop_api_host/0" do
    assert Host.pfop_api_host() == "http://api.qiniu.com"
  end
end
