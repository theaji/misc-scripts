#Get specific python version
FROM python:3.11.0a6-alpine3.15
#Set working directory
WORKDIR /code
#Copy requirements.txt to working directory
COPY requirements.txt /code
#Install requirements.txt 
RUN pip install -r requirements.txt --no-cache-dir
#Copy contents of folder to /code
COPY . /code
#Run app
CMD python app.py

