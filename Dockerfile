FROM quay.io/ibm_cpd_zen/zen-python:latest

COPY ./requirements.txt /tmp

RUN pip install -r /tmp/requirements.txt

COPY ./src /app/src
ENTRYPOINT ["/app/src/app.py"]
ENV HOME /tmp
USER 1001

