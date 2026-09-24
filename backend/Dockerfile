# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory
WORKDIR /app   

# Set environment variables to prevent Python from writing .pyc files and to ensure stdout and stderr are unbuffered
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY app ./app

# Expose the port the app runs on
EXPOSE 8000

# Set the command to run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]