FROM python:3.11-alpine

WORKDIR /app

RUN apk add --no-cache iputils curl iproute2 postgresql-dev gcc musl-dev bash net-tools

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8000

CMD ["python", "app.py"]
