FROM python:3.6

COPY requirements.txt /
RUN pip install -r requirements.txt

COPY templates/index.jinja2 /templates/
COPY hmc.py /


CMD [ "python", "hmc.py" ]

