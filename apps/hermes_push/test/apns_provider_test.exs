defmodule APNSProviderTest do
  use ExUnit.Case

  alias HPush.Provider.APNSProvider
  alias HPush.Provider.APNSConnectionRepository, as: ConnRepo

  setup do
    message = %{
      apns_cert: "-----BEGIN CERTIFICATE-----
MIIFhTCCBG2gAwIBAgIIEiW3s7HEIqswDQYJKoZIhvcNAQEFBQAwgZYxCzAJBgNV
BAYTAlVTMRMwEQYDVQQKDApBcHBsZSBJbmMuMSwwKgYDVQQLDCNBcHBsZSBXb3Js
ZHdpZGUgRGV2ZWxvcGVyIFJlbGF0aW9uczFEMEIGA1UEAww7QXBwbGUgV29ybGR3
aWRlIERldmVsb3BlciBSZWxhdGlvbnMgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkw
HhcNMTYwMTEyMDQ0OTE3WhcNMTcwMTExMDQ0OTE3WjCBhDEgMB4GCgmSJomT8ixk
AQEMEGNvbS5tYWtldXMuZGluZ28xPjA8BgNVBAMMNUFwcGxlIERldmVsb3BtZW50
IElPUyBQdXNoIFNlcnZpY2VzOiBjb20ubWFrZXVzLmRpbmdvMRMwEQYDVQQLDApW
Tk02V0tORzZXMQswCQYDVQQGEwJVUzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBAMyKYBIVtRLEbHiQ0PFsPePYLwcDWxM/7Pg2+qDxHtrT/FpuD8zAuj4h
y/geh0MZF8NvGNnponDwRWl7dbeZ8nZ4lXeC0irQ7dybnU1Y/GrsXho3uxkn8Ywr
+Vnp2/XBx0AaHriln1sfnUZG4l1XkRGp+OfeHIR7bI6j7gu2mAQl8P0Z8Zw1hBmK
m0LRr4J9degFDXi8sP7FgAgFPE49u1ivYR0IvBvhc0R1VT3vdtjKaOIBaxQEdYrJ
J3PovjDi0qd1h0zBXMgKBq57S030/mlnut0X8DAy7ceYDR+uzJ2/ykwYgPjBNOED
9Ozsc8gyyXBuhxjryEqNkuUSmAovKxsCAwEAAaOCAeUwggHhMB0GA1UdDgQWBBSL
JWiMZX+YHGJ4vYY5TmVwIXaqaTAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFIgnFwmp
thhgi+zruvZHWcVSVKO3MIIBDwYDVR0gBIIBBjCCAQIwgf8GCSqGSIb3Y2QFATCB
8TCBwwYIKwYBBQUHAgIwgbYMgbNSZWxpYW5jZSBvbiB0aGlzIGNlcnRpZmljYXRl
IGJ5IGFueSBwYXJ0eSBhc3N1bWVzIGFjY2VwdGFuY2Ugb2YgdGhlIHRoZW4gYXBw
bGljYWJsZSBzdGFuZGFyZCB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB1c2UsIGNl
cnRpZmljYXRlIHBvbGljeSBhbmQgY2VydGlmaWNhdGlvbiBwcmFjdGljZSBzdGF0
ZW1lbnRzLjApBggrBgEFBQcCARYdaHR0cDovL3d3dy5hcHBsZS5jb20vYXBwbGVj
YS8wTQYDVR0fBEYwRDBCoECgPoY8aHR0cDovL2RldmVsb3Blci5hcHBsZS5jb20v
Y2VydGlmaWNhdGlvbmF1dGhvcml0eS93d2RyY2EuY3JsMAsGA1UdDwQEAwIHgDAT
BgNVHSUEDDAKBggrBgEFBQcDAjAQBgoqhkiG92NkBgMBBAIFADANBgkqhkiG9w0B
AQUFAAOCAQEArriY5Z/vax/etGwoiyNrJox0Ri60Q9x+Do3lD/2/I6wnj0pAplZ5
ImY+unwImpso0t5pfE4RaZxNoN6vNYwZqBkWHn8JtCYXW5HFUQjEXkXc2uoMF1Ir
QIffM16Xm/N0wEbNTjKm0GsxtoDK7jKFmCA0pxKQVY8X8g0C+ukfgK2TLRo5KhXG
rb0VK/ujam7iCTxXXaR2eJyx+Kl2k0k4T5/1OKbtHOwlbO7C/+Vpz0j8xLKwPT5n
RUZ9yqfTzoDujSzpwC0MIFgabeUTl6CBaYmNPxtgKvaVZeShyKgH3gCzXoHy6q7p
WWvqGdjg1qYDOilTH7KpRYsgNmIjNKO2DA==
-----END CERTIFICATE-----
",
      apns_key: "-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAzIpgEhW1EsRseJDQ8Ww949gvBwNbEz/s+Db6oPEe2tP8Wm4P
zMC6PiHL+B6HQxkXw28Y2emicPBFaXt1t5nydniVd4LSKtDt3JudTVj8auxeGje7
GSfxjCv5Wenb9cHHQBoeuKWfWx+dRkbiXVeREan4594chHtsjqPuC7aYBCXw/Rnx
nDWEGYqbQtGvgn116AUNeLyw/sWACAU8Tj27WK9hHQi8G+FzRHVVPe922Mpo4gFr
FAR1isknc+i+MOLSp3WHTMFcyAoGrntLTfT+aWe63RfwMDLtx5gNH67Mnb/KTBiA
+ME04QP07OxzyDLJcG6HGOvISo2S5RKYCi8rGwIDAQABAoIBAAcY3hCClE/cZO8i
Bz35RYR8YdVadnSKiUxri/K9qxZouJ7ipsWyAkRZo9wuIv9fBYYQespE4xAMJjxs
vj7qppEZygXlkilOKpK3C5Q9fDSxkupR+Ln8utLkS7ik9q7mVGWTAnHhvU/KHwjr
OLuIaE42mZ5iBJdMOQ4R/haF9WxfXMN8OuOADtOyJE56q9PA+SRR5tQYGaKMQ7Ui
iccappDhMACg7OCth8QB/VC2p5uhDDdZCcEKqeU6e9Vs7GZlUpSxbz0TQjZ8iK/o
C7YlvqkJv+/FQhNCYi8H2UC+XGHs3SfQWy0KpkRQW6Bt9fXCJg7wvbIKcAhQqeo1
olpsiGECgYEA7QyO3P+0NI8dXrPedxr+zHsr+O1yraJuNVzPawh0pmesia9/90iy
/hq/o600QuphmKKurfqqaL7aakGHHTJcJmtm8eKdh+gHTfRBDjS5uujt0xQZLgka
UeYHsOvTQq6C+hu9YiGARta6xgnXalj9kOymPJAHebBdbdRd+EdNdxMCgYEA3OR/
jjmOVTKB81A/SbF69WGyrL+lOyA8eDetuMVmRsDbHXiwAE9rpkxpN62N6SXy2ajH
eDFlbWZYcRrhT5Cuo+bycnVXeNDXXCO9/yjUDWB1SugoND9ccWSZjz7vAButfmG4
OQbH3/jg8Y54gtLwWCONOq+acsRwSarC+HchVNkCgYBVzoTsVJc7q057WGq//IKd
LDznl7Q6TCDOqjDe0qm/DqozENcmgSdhufcC3ZCcZFE9ui23BpSm4+cWLXAmTnNy
6M/T4S8a4g+61R6zcLyGfwiPrqfKtTrUyIqiLUtEyPzaYi40lmHjwpjLVQaoFVx8
GF24cH50OzYmqof1doIBBwKBgGrpjXNhGCrUT2FcrcUVSdYKe1hxSZ/ccmgdSs/r
ex0zqtoQ197OkePjh+mS7uSxoWEH98OM5PKWXqgfwn2oIV7jIOWVNckcC6BlDEi7
kicHUL34r7zaDfw0HL7gTv1WaBqLYYb4aTVWWEmSE3H+dqWyT2DgLXju6wo8xDFO
N6vBAoGAeqs+JTXV1crVEwCTiMaWXE2XkNR24nir5B6+dF4ME5oKr8QDO5WZHyDi
Rw8YkkPV0I8FtcMfD34wDWKcaf6kBB2WOckzbVQT/Qf8bAPWdTDoqtu9UKwdu6dn
J4V+GbvbrBz/5xVIReA6F3X1+KL3vJ3IcuqAiqUb9uz8fhrRhbE=
-----END RSA PRIVATE KEY-----
",
      apns_env: :dev,
      body: "body",
      extra: "{\"url\":\"dingo://post/yHhXfm\",\"type\":\"POST\",\"android\":{\"visible\":true,\"title\":\"죽창!!\",\"smallImage\":\"http://file.thisisgame.com/upload/tboard/user/2015/07/10/20150710030032_8190p.jpg\",\"body\":\"너도 한방 나도 한방 우리 모두 죽창 한방\",\"bigImage\":\"http://upload2.inven.co.kr/upload/2015/02/20/bbs/i3119459344.png\"}}",
      gcm_api_key: "AIzaSyBblgLAZHvvhM6gk3ZWcl7-mYQiuStsB40",
      push_id: "0J-6W4i-0O6i-T-3J-Wybm-6ETm-ewzmg",
      push_tokens: [
        %{
          "pushToken" => "9aaf5cfb62e4d8d60bd6d51183efbd3893fb38631690c654e75b9955dc67ad01",
          "pushType" => "APN"
         },
        %{
          "pushToken" => "e2f8cfb9e5dfea860704bc5ae78b438e08ebfc31820a2018bf58ce99e120b232",
          "pushType" => "APN"
        },
        %{
          "pushToken" => "fb58cc8d02b84117b8158aaae82c87a5d05ddb0708b502a0aae824cecbd64274",
          "pushType" => "APN"
        },
        %{
          "pushToken" => "9b7f5d18331a6e93ce28516629e7e30e156a382bfc8f6044b128331f125bd6e5",
          "pushType" => "APN"
        },
        %{
          "pushToken" => "d5a6f5f208306ca362c0c44b33916f2f74e5986e4b729eaa1ff2abdb52c9d90b",
          "pushType" => "APN"
        },
  ],
  service_id: "0J-6W4i-0O6i-T",
  title: "title"}

    {:ok, message}
  end

  test "test", message do
    ConnRepo.start_link
    {:ok, pid} = APNSProvider.start_link
    g_message = Map.drop(message, [:gcm_api_key, :push_tokens])
    g_tokens = Map.get(message, :push_tokens)
    |> Enum.filter(fn(token) -> Map.get(token, "pushType") == "APN" end)
    |> Enum.map(fn(token) -> Map.get(token, "pushToken") end)

    APNSProvider.publish(pid, g_message, g_tokens)
    :timer.sleep 5000

    assert 1 == 1
  end

end
