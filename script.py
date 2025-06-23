import requests
import boto3
import json
from datetime import datetime

# parámetros bucket
BUCKET_NAME = "citybikesproject"
KEY_NAME = f"api_data/response_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

# URL API
API_URL = "https://api.citybik.es/v2/networks/ecobici-buenos-aires"

def main():
    # call API
    response = requests.get(API_URL)
    response.raise_for_status()
    data = response.json()

    # subir a s3
    s3 = boto3.client("s3")
    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=KEY_NAME,
        Body=json.dumps(data),
        ContentType="application/json"
    )


if __name__ == "__main__":
    main()
