FROM python:3.11-alpine

WORKDIR /app

RUN apk add --no-cache iputils curl iproute2 sqlite bash net-tools

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
