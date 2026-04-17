import urllib.request
import urllib.parse
from urllib.error import HTTPError
import json

headers = {
    'x-rapidapi-host': 'download-videos-tiktok.p.rapidapi.com',
    'x-rapidapi-key': '7f02dcb732mshe0adcde39d9a2b1p183a68jsn1c4b7d554208',
}

test_video_url = 'https://www.tiktok.com/@tiktok/video/7106594312292453678'

# Test paths
paths = [
    '/',
    '/video/info',
    '/api/v1/info',
    '/media/info',
    '/searchvideo' # To see if this actually works (should return error since no keywords)
]

for p in paths:
    params = urllib.parse.urlencode({'url': test_video_url})
    url = f'https://download-videos-tiktok.p.rapidapi.com{p}?{params}'
    print(f"Testing GET {url}")
    req = urllib.request.Request(url, headers=headers, method='GET')
    try:
        with urllib.request.urlopen(req) as response:
            data = response.read().decode('utf-8')
            print(f"Success! Status: {response.status}")
            print(f"Data snippet: {data[:200]}...")
    except HTTPError as e:
        print(f"Failed! Status: {e.code}")
    except Exception as e:
        print(f"Error: {e}")
