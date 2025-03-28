#set environment
FROM python:3.9-slim

#set working directory
WORKDIR /app

#copy the current directory contents into the container at /app
COPY . /app

#install dependencies

RUN pip install --no-cache-dir -r requirements.txt

#command to run on container start

CMD ["gunicorn", "--bind", "0.0.0.0:5001", "app:app"]