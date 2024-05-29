FROM python:3.11-slim

WORKDIR /app

ENV PYTHONUNBUFFERED 1

RUN apt update && apt upgrade -y && apt install -y libpq5

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY src/. .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
