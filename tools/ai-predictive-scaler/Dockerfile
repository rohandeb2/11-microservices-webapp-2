FROM python:3.9-slim
RUN pip install requests openai<1.0.0 kubernetes
COPY scaler.py .
CMD ["python", "scaler.py"]