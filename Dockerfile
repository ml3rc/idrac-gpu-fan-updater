FROM python:3.11-slim

WORKDIR /app

COPY app.py .

RUN pip install requests pyyaml

# racadm must exist → you will mount or install it
CMD ["python", "app.py"]