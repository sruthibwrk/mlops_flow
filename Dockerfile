FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN uv pip install --no-cache-dir --system -r requirements.txt

COPY api.py .
COPY models/ models/

EXPOSE 8000

CMD ["python", "api.py"]
