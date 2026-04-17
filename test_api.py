import urllib.request
import json
import urllib.error

url = "https://download-videos-tiktok.p.rapidapi.com/"
headers = {
    "x-rapidapi-host": "download-videos-tiktok.p.rapidapi.com",
    "x-rapidapi-key": "7f02dcb732mshe0adcde39d9a2b1p183a68jsn1c4b7d554208",
    "Content-Type": "application/json"
}

def test_endpoint(endpoint, method="GET", data=None):
    req_url = url + endpoint if not url.endswith('/') and not endpoint.startswith('/') else url.rstrip('/') + '/' + endpoint.lstrip('/')
    req = urllib.request.Request(req_url, headers=headers, method=method)
    if data:
        req.data = json.dumps(data).encode('utf-8')
    try:
        with urllib.request.urlopen(req) as response:
            print(f"[{method}] /{endpoint} -> {response.status}")
            print(response.read().decode('utf-8')[:200])
    except urllib.error.HTTPError as e:
        print(f"[{method}] /{endpoint} -> Error: {e.code}")
    except Exception as e:
        print(f"[{method}] /{endpoint} -> Error: {e}")

endpoints = ["download", "info", "tiktok", "video", "tiktok/info", "tiktok/video", "tiktok/download", "api/download", "api/video", "aweme/v1/web/aweme/detail"]
for ep in endpoints:
    test_endpoint(ep, method="GET")
    test_endpoint(ep, method="POST", data={"url": "https://www.tiktok.com/@tiktok/video/7106594312292453675"})
