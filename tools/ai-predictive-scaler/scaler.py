import time
import os
import requests
import openai
from kubernetes import client, config

# Setup
openai.api_key = os.getenv("AI_LOG_ANALYZER_KEY") # Reuse your existing key
PROMETHEUS_URL = "http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"

def get_current_rps():
    # Query Prometheus for total requests per second
    query = 'sum(rate(http_requests_total[2m]))'
    response = requests.get(f"{PROMETHEUS_URL}/api/v1/query", params={'query': query})
    results = response.json()['data']['result']
    return float(results[0]['value'][1]) if results else 0

def predict_required_replicas(current_rps):
    prompt = f"Current traffic is {current_rps} requests/sec. If traffic grows by 20% in the next 5 mins, how many pods are needed if 1 pod handles 50 rps? Return ONLY a single integer."
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )
    return int(response.choices[0].message.content.strip())

def scale_deployment(replicas):
    config.load_incluster_config() # Works when running inside K8s
    apps_v1 = client.AppsV1Api()
    apps_v1.patch_namespaced_deployment_scale(
        name="frontend", # Target your frontend
        namespace="default",
        body={"spec": {"replicas": replicas}}
    )
    print(f"Scaled frontend to {replicas} replicas based on AI prediction.")

if __name__ == "__main__":
    while True:
        rps = get_current_rps()
        needed = predict_required_replicas(rps)
        scale_deployment(needed)
        time.sleep(60) # Predict every minute