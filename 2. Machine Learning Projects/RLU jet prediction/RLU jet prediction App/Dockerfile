# Base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy all files (including templates/ and static/)
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port
EXPOSE 7860

# Run the app
CMD ["python", "app.py"]