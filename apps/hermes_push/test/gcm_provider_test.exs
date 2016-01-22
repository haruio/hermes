defmodule GCMProviderTest do
  use ExUnit.Case

  alias HPush.Provider.GCMProvider

  setup do
  	message = %{apns_cert: "Bag Attributes\n    friendlyName: Apple Development IOS Push Services: com.makeus.dingo\n    localKeyID: C7 0A 3E C3 C4 26 31 7F 74 E2 7D FC 5D 0C 44 52 D4 21 45 38 \nsubject=/UID=com.makeus.dingo/CN=Apple Development IOS Push Services: com.makeus.dingo/OU=VNM6WKNG6W/C=US\nissuer=/C=US/O=Apple Inc./OU=Apple Worldwide Developer Relations/CN=Apple Worldwide Developer Relations Certification Authority\n-----BEGIN CERTIFICATE-----\nMIIFhTCCBG2gAwIBAgIIPmr6sFuc2xQwDQYJKoZIhvcNAQEFBQAwgZYxCzAJBgNV\nBAYTAlVTMRMwEQYDVQQKDApBcHBsZSBJbmMuMSwwKgYDVQQLDCNBcHBsZSBXb3Js\nZHdpZGUgRGV2ZWxvcGVyIFJlbGF0aW9uczFEMEIGA1UEAww7QXBwbGUgV29ybGR3\naWRlIERldmVsb3BlciBSZWxhdGlvbnMgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkw\nHhcNMTUxMTMwMDUxNzMxWhcNMTYxMTI5MDUxNzMxWjCBhDEgMB4GCgmSJomT8ixk\nAQEMEGNvbS5tYWtldXMuZGluZ28xPjA8BgNVBAMMNUFwcGxlIERldmVsb3BtZW50\nIElPUyBQdXNoIFNlcnZpY2VzOiBjb20ubWFrZXVzLmRpbmdvMRMwEQYDVQQLDApW\nTk02V0tORzZXMQswCQYDVQQGEwJVUzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC\nAQoCggEBAMCBOmrr4tpJzjYC5qquRuPgtEexkjqFS/WafLbXcGf+lUzRILq8AGQm\n0HUD/eaBYm7XCwhW2JcK6R95de4T2TCaefPhWudeEpmldg2LXU/uJWNGiYhN38Uo\nbKvdZVdSnv/XPHofHm1xWlnWT0yWoIzYQySbzb7MRS08QsAyL/9/EhfrQxpq3uFf\nfR6J+KO3UvX3jxNpyvMO2iBchN9ebQbhCw+RQdfDEvOAZDlxcdXoy4hwvC3vEYM8\n811sGMN1ImSYP+i/NWA1hL4TdN54xMwNO/oXSXhBit6FkNiacKRYyf3bQpxMtOA1\nmVZ4bK6M+yxh0kcIlrNuAhty9P2NlYUCAwEAAaOCAeUwggHhMB0GA1UdDgQWBBTH\nCj7DxCYxf3TiffxdDERS1CFFODAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFIgnFwmp\nthhgi+zruvZHWcVSVKO3MIIBDwYDVR0gBIIBBjCCAQIwgf8GCSqGSIb3Y2QFATCB\n8TCBwwYIKwYBBQUHAgIwgbYMgbNSZWxpYW5jZSBvbiB0aGlzIGNlcnRpZmljYXRl\nIGJ5IGFueSBwYXJ0eSBhc3N1bWVzIGFjY2VwdGFuY2Ugb2YgdGhlIHRoZW4gYXBw\nbGljYWJsZSBzdGFuZGFyZCB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB1c2UsIGNl\ncnRpZmljYXRlIHBvbGljeSBhbmQgY2VydGlmaWNhdGlvbiBwcmFjdGljZSBzdGF0\nZW1lbnRzLjApBggrBgEFBQcCARYdaHR0cDovL3d3dy5hcHBsZS5jb20vYXBwbGVj\nYS8wTQYDVR0fBEYwRDBCoECgPoY8aHR0cDovL2RldmVsb3Blci5hcHBsZS5jb20v\nY2VydGlmaWNhdGlvbmF1dGhvcml0eS93d2RyY2EuY3JsMAsGA1UdDwQEAwIHgDAT\nBgNVHSUEDDAKBggrBgEFBQcDAjAQBgoqhkiG92NkBgMBBAIFADANBgkqhkiG9w0B\nAQUFAAOCAQEAuDFiBO1y4mnpZm66GoBeTMNw1makqE+Dk4Ob9KEJXC982/lnlqrf\n/Saha02O1Mn8gPB+sBfFfTYKH6muxEMbkfEL1RL0imqknaFCeLTnwKdGed7nMd0J\nL1sw40zmTG7KCZNNzRB7LB8PDPbdRZLfN3DqRm0RgRHpohG2CEtn/sxxblR9SXgV\nTTCxujKo2dEzMC6UesdlOmXGxglsocVOBpxdzMOiwTHQvyt7DOboaR840TekA4CK\nBMG4vdp1agMI73RYakIqCQCeOYXrBMqdUggeOK6T6V03WZrIZWtdHd3zX4FL53ZV\nxmPPqLcvcHf5PDqp8K6wL9luZPt3Z9PUxg==\n-----END CERTIFICATE-----\n",
  apns_env: :dev,
  apns_key: "-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAwIE6auvi2knONgLmqq5G4+C0R7GSOoVL9Zp8ttdwZ/6VTNEg\nurwAZCbQdQP95oFibtcLCFbYlwrpH3l17hPZMJp58+Fa514SmaV2DYtdT+4lY0aJ\niE3fxShsq91lV1Ke/9c8eh8ebXFaWdZPTJagjNhDJJvNvsxFLTxCwDIv/38SF+tD\nGmre4V99Hon4o7dS9fePE2nK8w7aIFyE315tBuELD5FB18MS84BkOXFx1ejLiHC8\nLe8RgzzzXWwYw3UiZJg/6L81YDWEvhN03njEzA07+hdJeEGK3oWQ2JpwpFjJ/dtC\nnEy04DWZVnhsroz7LGHSRwiWs24CG3L0/Y2VhQIDAQABAoIBACY7hDaoEq336pSf\njuBnLH0lq6hxg/FLeAKXZB2MPC7rSQuwnSd5HzrE2rHi0RJur/YDj5VgajPVXud5\nYAqgtooIpB/jqgI5lMgfLIsUGrw9N/+3iqkfjknB9ZNMrUvihOGbBc/bTle+I4uk\nHKvBXrGaYftrVjmGqFaLmVZCoXXEllJu1ki/tg/l0DgydHuQ5Ii+KGWTtXozyMxr\n1cJEnm03MiSQ85ZdXSg2qpIftEZ+w2/lv3A5cPhNsMxOmb5YgtArpdcvlQoI/ryN\ndpx/B8RmHdZTOefvH6Jld5g5pakSPuU0HTfYXR599R10a/I4eSQKfgwTugHqRvqu\n8KivsCECgYEA9mbJKHwd+dGkUTt0KGG1DkBt+/LJk7yt1gDFETovbBiCtPmgOTYF\nZSm4wBWAqw7puhHBoqphnEkqVig+JoZq/qiJKdpc8aej/Gky7GD9gPPFKQxBOOP5\nPy6XaymLKiKOuVe8bCYHtoiQSGp0UbgndzJm6wGHOQWydvVonbq4Vk8CgYEAyAD2\ngV9m4Ur5UgDtmTng6Mmf5TAfSkrPGTQc1lZ25YRdZ6JjvCz47bfEcIQIkSh9iRJu\nmfJ2npL/tgdnalpC6xO68iA26V+MzAm9sp66RsRXIpN/1dPUV00Ec3Uh4jmR5MKy\nsbkIAOHkLt5L+/4E/z77piitJTz9S8xlECYINesCgYA+PRROn5tKwQOKaUQb9yIu\nqWOeomL8aEpYpfUhNttHqKFLaUppaRXPycwa6NOJYcjz8QxCNFtXiLui66NXQ9i+\n3n9XDQsxFzE6zq/IOW+PJQQGLExFPIB2zyP8M5AtYnE+q8SyZKDKIJChWhJrmeKO\nHzMT5VzssF214qM8RC/PzQKBgGoZ0Ku7P6m/C1rMcT97K+xyoeeEyuSvoQQe2DmA\nrxx9RsvmowA932TEu2pxMNZI46fm5lO3A+SF2S/o55zM+3kYA3HVUywk612GwWLT\nv8AxAoSuOP/nm1sg2X6iofIQVmxEOWX84dkN/O48MZUiIeaCtB9mrsv1ee5PJUIW\n2v43AoGACeILwV32b2FFcpp0YdkhyDFhwd0mJxljQefbEWvISKJgkztQQZ23QU7P\nVo5jHKJzERxM6FyxNDGn0IHAgmLcfoENj2tATXrowc7Ubld+SGljq2j9+PGmwtHq\nqF7VA+DJ45BifIMsePQCZZPOg0ERdTD6ogYQdh/5VOBSY+5GOr4=\n-----END RSA PRIVATE KEY-----",
  body: "body",
  extra: "{\"url\":\"dingo://post/yHhXfm\",\"type\":\"POST\",\"android\":{\"visible\":true,\"title\":\"죽창!!\",\"smallImage\":\"http://file.thisisgame.com/upload/tboard/user/2015/07/10/20150710030032_8190p.jpg\",\"body\":\"너도 한방 나도 한방 우리 모두 죽창 한방\",\"bigImage\":\"http://upload2.inven.co.kr/upload/2015/02/20/bbs/i3119459344.png\"}}",
  gcm_api_key: "AIzaSyBblgLAZHvvhM6gk3ZWcl7-mYQiuStsB40",
  push_id: "0J-6W4i-0O6i-T-3J-Wybm-6ETm-ewzmg",
  push_tokens: [%{"pushToken" => "fvEcs23J-wY:APA91bHvo_D8sd1K69o6VqsTJZniZEeCQA3RyD55E94VUWZYF3_txAv55R9DLfLYOH6GHk1A23BIKXBzWnOmPdH3eOEN0ZHE5NnErjejgUMCk2SWKuwfd017hO4ceMVCk8UuV3nfsPW5",
     "pushType" => "GCM", "uuid" => "-111"},
   %{"pushToken" => "d3F5NrIwwyI:APA91bEMwqGpCgooxZ1I2esXE3GZS2-sb0mZFZmHtM6CYRo_-iyJBHEJ_E_wKIkyMWH16xwdIVwXam-bKbclTdRr2VXDE2DxdKnurq4NfRJB4DEuIc_ElD2yQlsAUHPQRheJN8oB-c2i",
     "pushType" => "GCM", "uuid" => "-555"},
   %{"pushToken" => "eL6XbcQls9Q:APA91bFXbB8XzkurZoan-3rgTRVTmVcokHERDGAc2NY8mY9vIe42X2e-dHT3h_tGWIaJy6u2dn8_ivN4PVPNe4hrrvT1l0q280K733FbpLGLFIlGK-sgTI4HVE8BYZbEj_ivDBm7jtUN",
     "pushType" => "GCM", "uuid" => "222"},
   %{"pushToken" => "fmXspIOYsb4:APA91bHT6ArzquPjnnqZqeEMNBhx6ag99wjc9uuY9GQczLnqKmlMHY6aE02sAitMD8zapVmFH5I8nEohINGetVGhm8DwjwCr3oxch-D05YkQB9QduG66vNIGIJcudncM_RHGQ5bQB-3J",
     "pushType" => "GCM", "uuid" => "333"},
   %{"pushToken" => "d9WIdagzpSw:APA91bEwYTjyP9mF1vvOxpxb9U3I8Z2EN96JWjHt2y-Y7M_UWe89DCqjs1GI0e1MKfQSBWatxq5cjsHA61RJ4wuaDw7H3-1WlpOJTGgHvroq1-w8uEvCMHD1bht-vyMKUgCrfQz-6Y1R",
     "pushType" => "GCM", "uuid" => "444"},
   %{"pushToken" => "cGlc-q-5-kc:APA91bFd895NtCEQdx1Rjl5MIuyMhXJ1A1V1V595h1LzqEqqrIEaEfwN2oGtnrAuZujznxftK4XHWzWCv4F9BNOKkFOQEJsDL3x0dIN6Qaa39uRP31ekxmqwZaRC8A-humaeostlqqg7",
     "pushType" => "GCM", "uuid" => "666"},
   %{"pushToken" => "chbkAp-6dl8:APA91bFQpmEZO8BaQKHGbsqWVA2Zp0lU5HUqDcFCCW0_lBB6nP-js4lzmmdJQQucINdVn5r4ZjtKsUK2kbdVk7wHaMEJ6AqlSH-W2vTOerouZipqDSKkhX-jNd1J4SRvZotnOjOo4kGq",
     "pushType" => "GCM", "uuid" => "777"},
   %{"pushToken" => "fDWPOyUxBvs:APA91bFJM6ibE5-DqH79Pd0PlzMb9X-QAVspTi32Qva50tjvlZMD9NEcF7UEl0F5Ti6Qq1JQ1fPoRVuJlAQxHNUO2HA2Cp7UV_KAVomlN7LipFsemsvpbBZh2M8ecTe1CGItv1kHev0L",
     "pushType" => "GCM", "uuid" => "888"},
   %{"pushToken" => "eL6XbcQls9Q:APA91bFXbB8XzkurZoan-3rgTRVTmVcokHERDGAc2NY8mY9vIe42X2e-dHT3h_tGWIaJy6u2dn8_ivN4PVPNe4hrrvT1l0q280K733FbpLGLFIlGK-sgTI4HVE8BYZbEj_ivDBm7jtUN",
     "pushType" => "GCM", "uuid" => "999"}], service_id: "0J-6W4i-0O6i-T",
  title: "title"}

  	{:ok, message}
  end

  test "start gcm provider" do
    {:ok, pid} = GCMProvider.start_link

    assert is_pid(pid)
  end

  test "build extra data", message do
    assert %{
      "url" => _url,
      "type" => _type,
      "visible" => _visible,
      "title" => _title,
      "body" => _body,
      "smallImage" => _small_image,
      "bigImage" => _big_image,
      "pushId" => _push_id,
      "feedback" => _feedback
    } = GCMProvider.build_extra_data(message, "feedback_url")
  end

  test "build gcm message", message do
    assert %{
      "notification" => _notification,
      "data" => _data
    } = GCMProvider.build_payload(message)
  end

  test "publish gcm message", message do
    {:ok, pid} = GCMProvider.start_link(Application.get_env(:hermes_push, GCMProvider))
    g_message = Map.drop(message, [:apns_cert, :apns_key, :apns_dev, :push_tokens])
    g_tokens = Map.get(message, :push_tokens)
    |> Enum.filter(fn(token) -> Map.get(token, "pushType") == "GCM" end)
    |> Enum.map(fn(token) -> Map.get(token, "pushToken") end)

    assert = GCMProvider.publish(pid, g_message, g_tokens) == :ok
  end
end
