import requests
import sys

# Server URL
SERVER_URL = "http://127.0.0.1:5000/test"

def test_game_server():
    try:
        print(f"🔄 Testing game server at {SERVER_URL}...")

        # Make a request to the /test endpoint
        response = requests.get(SERVER_URL)
        data = response.json()

        if response.status_code == 200 and data.get("player_exists"):
            print("✅ SUCCESS: 'Sarumae' exists, and the server is running correctly!")
            sys.exit(0)  # Exit with success code
        else:
            print("❌ ERROR: 'Sarumae' is missing or test failed.")
            print(f"Response: {data}")
            sys.exit(1)  # Exit with failure code

    except requests.exceptions.RequestException as e:
        print(f"❌ ERROR: Could not reach the game server - {e}")
        sys.exit(1)  # Exit with failure code

if __name__ == "__main__":
    test_game_server()
