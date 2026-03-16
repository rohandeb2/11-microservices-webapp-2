FROM python:3.9-slim
RUN pip install elasticsearch "openai<1.0.0" 
COPY app.py .
CMD ["python", "app.py"]



# # # Force the job to run manually
# kubectl create job --from=cronjob/ai-log-analyzer manual-test-ai -n elk

# # Check the logs immediately
# kubectl logs -l job-name=manual-test-ai -n elk

# to run it

# argocd/apps/ai-analyzer.yaml and tools/ai-analyzer/app.py are gorup to run this ai scipts. You can deploy it using ArgoCD or run it locally using Docker.