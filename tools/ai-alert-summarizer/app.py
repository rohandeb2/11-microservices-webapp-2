import os
from flask import Flask, request
import openai
import requests

app = Flask(__name__)

# Load API Keys from Env Vars (Injected by K8s)
openai.api_key = os.getenv("AI_LOG_ANALYZER_KEY")
SLACK_WEBHOOK = os.getenv("SLACK_WEBHOOK_URL")

@app.route('/webhook', methods=['POST'])
def alert_handler():
    data = request.json
    
    # Senior Tip: Check if the alert is firing or resolved
    status = data.get('status', 'firing').upper()
    alert_details = ""
    
    for alert in data.get('alerts', []):
        name = alert['labels'].get('alertname', 'Unknown')
        summary = alert['annotations'].get('summary', 'No summary')
        alert_details += f"Alert: {name}\nDetails: {summary}\n"

    # AI Prompt for Smart Summarization
    prompt = f"Status: {status}\n{alert_details}\nSummarize this for a DevOps Slack channel. Include a 'Root Cause Guess' and 'Immediate Next Step'."

    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )

    ai_summary = response.choices[0].message.content
    
    # Send to Slack
    requests.post(SLACK_WEBHOOK, json={"text": f"🧠 *AI Smart Alert* 🧠\n{ai_summary}"})
    
    return "OK", 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)