import urllib.request
import urllib.parse
from urllib.error import HTTPError
import json

headers = {
    'x-rapidapi-host': 'download-videos-tiktok.p.rapidapi.com',
    'x-rapidapi-key': '7f02dcb732mshe0adcde39d9a2b1p183a68jsn1c4b7d554208',
    'Content-Type': 'application/json'
}

data_payload = json.dumps({'url': 'https://www.tiktok.com/@tiktok/video/7106594312292453678', 'hd': '1'}).encode('utf-8')

urls_to_test = [f'https://download-videos-tiktok.p.rapidapi.com/video', 
                f'https://download-videos-tiktok.p.rapidapi.com/',
                f'https://download-videos-tiktok.p.rapidapi.com/analyze',
                f'https://download-videos-tiktok.p.rapidapi.com/info']

for u in urls_to_test:
    print(f"Testing POST {u}")
    req = urllib.request.Request(u, data=data_payload, headers=headers, method='POST')
    try:
        with urllib.request.urlopen(req) as response:
            print(f"Success! Status: {response.status}")
    except HTTPError as e:
        print(f"Failed! Status: {e.code}")
