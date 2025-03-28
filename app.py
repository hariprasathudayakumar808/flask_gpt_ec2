# Description: A simple code that will host a Flask server and will be used to interact with the GPT-4 API

# Importing the required libraries
from flask import Flask, request, jsonify
import requests
import os
from dotenv import load_dotenv

# Loading the environment variables
load_dotenv()

# Creating the Flask app
app = Flask(__name__)

# BASECLIENT CLASS
class BaseClient:
    def __init__(self, base_url, auth_token):
        self.base_url = base_url
        self.headers = {
            "Authorization": f"Bearer {auth_token}",
            "Content-Type": "application/json"
        }

    def send_request(self, relative_url, http_body):
        response = requests.post(self.base_url + relative_url, json=http_body, headers=self.headers)
        return self.handle_request(response)

    def handle_request(self, response):
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(f"Request failed with status code {response.status_code}: {response.text}")

# GPTCLIENT CLASS
class GPTClient(BaseClient):
    def __init__(self, base_url, auth_token):
        super().__init__(base_url, auth_token)

    def send_request(self, http_body):
        return super().send_request(gpt_relative_url, http_body)

# Setting the environment variables
openai_api_key = os.getenv("OPENAI_API_KEY")
gpt_base_url = "https://api.openai.com/v1/"
gpt_relative_url = "chat/completions"

@app.route("/chat", methods=["POST"])
def chat():
    try:
        # Get the prompt from the request
        data = request.get_json()
        prompt = data.get("prompt", "")
        if not prompt:
            return jsonify({"error": "Prompt is required"}), 400

        # Prepare the HTTP body for the GPT request
        gpt_http_body = {
            "model": "gpt-4",
            "messages": [
                {"role": "system", "content": "Story teller"},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.7
        }

        # Send the request to GPT-4
        gpt_client = GPTClient(gpt_base_url, openai_api_key)
        gpt_response = gpt_client.send_request(gpt_http_body)

       # Extract the content from the response
        message_content = gpt_response.get("choices", [])[0].get("message", {}).get("content", "")

        # Return the GPT response
        return jsonify({"response": message_content}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)