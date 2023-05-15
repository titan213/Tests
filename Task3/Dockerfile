FROM python:3 AS builder
WORKDIR /app

#Install dependencies 
RUN pip install --no-cache-dir flask

#Copy the code for both services
COPY app_a.py /app/scripts/
COPY app_b.py /app/scripts/


#Build seperate service images 
FROM builder AS service_a
WORKDIR /app/scripts
EXPOSE 5000
CMD ["python", "/app/scripts/app_a.py"]

FROM builder AS service_b
WORKDIR /app/scripts
EXPOSE 5000
CMD ["python", "/app/scripts/app_b.py"]