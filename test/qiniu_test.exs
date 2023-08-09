defmodule QiniuTest do
  use ExUnit.Case

  test "override config" do
    assert Qiniu.config()[:access_key] == "key"
  end

  test "default region is z0" do
    assert Qiniu.region() == "z0"
  end
end
