FROM python:3.9-slim
RUN pip install flask openai<1.0.0 requests
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]