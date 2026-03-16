import os
from elasticsearch import Elasticsearch
import openai

# --- 1. SET THE API KEY (CRITICAL FIX) ---
# This pulls the key injected from AWS Secrets Manager via your K8s manifest
openai.api_key = os.getenv("AI_LOG_ANALYZER_KEY")

# 2. Connect to your ELK Stack
# Ensure ELK_URL is set to http://elasticsearch:9200 in your K8s env
es = Elasticsearch([os.getenv('ELK_URL', 'http://elasticsearch:9200')])

# 3. Query for Errors in the last 15 mins
query = {
    "query": {
        "bool": {
            "must": [
                # Senior Tip: Some logs use 'ERROR' or 'error'—match both or use wildcards
                {"match": {"log.level": "error"}},
                {"range": {"@timestamp": {"gte": "now-15m"}}}
            ]
        }
    }
}

try:
    res = es.search(index="logstash-*", body=query)
    
    if not res['hits']['hits']:
        print("No errors found in the last 15 minutes. Cluster is healthy!")

    # 4. Send to AI for Analysis
    for hit in res['hits']['hits']:
        # Extract metadata so the AI knows which service is failing
        service_name = hit['_source'].get('kubernetes', {}).get('container_name', 'unknown')
        log_data = hit['_source'].get('message', 'No message field found')
        
        print(f"--- Analyzing Error in {service_name} ---")
        
        response = openai.ChatCompletion.create(
            model="gpt-4", # Or gpt-3.5-turbo for lower cost
            messages=[
                {"role": "system", "content": "You are a Senior SRE. Analyze the following log from a Kubernetes microservice. Identify the root cause and provide a brief fix."},
                {"role": "user", "content": f"Service: {service_name}\nLog: {log_data}"}
            ]
        )
        print(f"AI Root Cause Analysis: {response.choices[0].message.content}\n")

except Exception as e:
    print(f"Error connecting to Elasticsearch or OpenAI: {e}")