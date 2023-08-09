defmodule Qiniu.ResourceTest do
  use ExUnit.Case

  alias Qiniu.Resource
  alias Qiniu.HTTP

  import Mock

  test "stat" do
    with_mock HTTP, auth_post: fn "https://rs-z0.qiniuapi.com/stat/Yjpr", "" -> "response" end do
      assert Resource.stat("b:k") == "response"
    end
  end

  test "copy" do
    with_mock HTTP,
      auth_post: fn "https://rs-z0.qiniuapi.com/copy/Yjpr/YjE6azE=", "" -> "response" end do
      assert Resource.copy("b:k", "b1:k1") == "response"
    end
  end

  test "move" do
    with_mock HTTP,
      auth_post: fn "https://rs-z0.qiniuapi.com/move/Yjpr/YjE6azE=", "" -> "response" end do
      assert Resource.move("b:k", "b1:k1") == "response"
    end
  end

  test "delete/1" do
    with_mock HTTP, auth_post: fn "https://rs-z0.qiniuapi.com/delete/Yjpr", "" -> "response" end do
      assert Resource.delete("b:k") == "response"
    end
  end

  test "delete/2" do
    with_mock HTTP,
      auth_post: fn "https://rs-z0.qiniuapi.com/deleteAfterDays/Yjpr/2", "" -> "response" end do
      assert Resource.delete("b:k", 2)
    end
  end

  test "batch" do
    with_mock HTTP,
      auth_post:
        fn "https://rs-z0.qiniuapi.com?op=/stat/Yjpr&op=/copy/Yjpr/YjE6azE=&op=/move/Yjpr/YjE6azE=&op=/delete/Yjpr",
           "" ->
          "response"
        end do
      assert Resource.batch([
               [:stat, "b:k"],
               [:copy, "b:k", "b1:k1"],
               [:move, "b:k", "b1:k1"],
               [:delete, "b:k"]
             ]) == "response"
    end
  end

  test "list with no options" do
    with_mock HTTP,
      auth_post: fn "https://rsf-z0.qiniuapi.com/list?bucket=bucket", "" -> "response" end do
      assert Resource.list("bucket") == "response"
    end
  end

  test "list with options" do
    with_mock HTTP,
      auth_post:
        fn "https://rsf-z0.qiniuapi.com/list?bucket=bucket&limit=10&prefix=foo&delimiter=/&marker=m",
           "" ->
          "response"
        end do
      assert Resource.list("bucket", limit: 10, prefix: "foo", delimiter: "/", marker: "m") ==
               "response"
    end
  end

  test "fetch" do
    with_mock HTTP,
      auth_post:
        fn "https://iovip.qiniuio.com/fetch/aHR0cHM6Ly9pbWFnZS51cmw=/to/YnVja2V0OmtleQ==", "" ->
          "response"
        end do
      assert Resource.fetch("https://image.url", "bucket:key") == "response"
    end
  end

  test "prefetch" do
    with_mock HTTP,
      auth_post: fn "https://iovip.qiniuio.com/prefetch/YnVja2V0OmtleQ==", "" -> "response" end do
      assert Resource.prefetch("bucket:key") == "response"
    end
  end

  test "chgm" do
    with_mock HTTP,
      auth_post:
        fn "https://rs-z0.qiniuapi.com/chgm/YnVja2V0OmtleQ==/mime/YXBwbGljYXRpb24vanNvbg==", "" ->
          "response"
        end do
      assert Resource.chgm("bucket:key", "application/json") == "response"
    end
  end
end
