# Use official lightweight Python image
FROM python:3.9-slim

# Set working directory to /app
WORKDIR /app

# 1. Install System Dependencies (Minimal)
# We add curl for the healthcheck if needed, though we switched to python-native check
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Copy the Code Structure
# We explicitly copy backend and client to preserve the folder hierarchy
COPY ./backend /app/backend
COPY ./client /app/client

# 3. Install Python Dependencies
# We assume requirements.txt is inside the backend folder
COPY ./backend/requirements.txt /app/backend/requirements.txt
RUN pip install --no-cache-dir -r /app/backend/requirements.txt

# 4. Set Python Path
# This is CRITICAL. It lets Python "see" the backend folder as a package.
ENV PYTHONPATH=/app

# 5. Run the Application
# CHANGED: We now point to "backend.main:app" instead of just "main:app"
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]