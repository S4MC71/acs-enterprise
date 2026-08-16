FROM python:3.11-alpine

RUN apk add --no-cache curl net-tools
RUN pip install --no-cache-dir flask

WORKDIR /app
COPY nac-app.py app.py

EXPOSE 8100
CMD ["python3", "app.py"]
