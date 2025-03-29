# Step 1: Use an official Python runtime as a parent image
FROM python:3.9-slim

# Step 2: Set the working directory in the container
WORKDIR /app

# Step 3: Install any needed dependencies
RUN pip install requests

# Step 4: Copy the current directory contents into the container at /app
COPY . /app

# Step 5: Make port 8000 available to the world outside this container
EXPOSE 8000

# Step 6: Define environment variable
ENV NAME World

# Step 7: Run app.py when the container launches
CMD ["python", "app.py"]

