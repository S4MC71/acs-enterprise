FROM python:3.11-alpine

RUN pip install --no-cache-dir flask

WORKDIR /app
COPY saas-app.py app.py

EXPOSE 8443
CMD ["python3", "app.py"]
