FROM python:3.11-alpine

RUN apk add --no-cache curl net-tools

RUN pip install --no-cache-dir flask requests pyjwt cryptography

WORKDIR /app
COPY app.py .

EXPOSE 8080

CMD ["python3", "app.py"]
