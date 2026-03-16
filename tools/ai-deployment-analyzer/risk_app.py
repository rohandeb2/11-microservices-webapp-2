import os
import sys
import openai

openai.api_key = os.getenv("OPENAI_API_KEY")

def analyze_risk(diff_text):

    if not diff_text.strip():
        print("No code changes detected.")
        sys.exit(0)

    prompt = f"""
Analyze the following code changes for deployment risk.
Provide:

Risk Level: Low / Medium / High
Reason:
Suggested Action:

Changes:
{diff_text}
"""

    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )

    return response.choices[0].message.content


if __name__ == "__main__":

    with open(sys.argv[1], "r") as f:
        diff_text = f.read()

    report = analyze_risk(diff_text)

    print("🧠 --- AI DEPLOYMENT RISK REPORT --- 🧠")
    print(report)