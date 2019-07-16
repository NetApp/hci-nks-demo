#
# This is an example of a very very basic HTTP server in python with 17 lines of code.
# the aiohttp package handles most of the work and is a good choice
# for microservice workloads as it's fully async
#
# In this case we are also using the Jinja2 template engine to generate HTML
# aiohttp is often used as an API interface and can handle JSON formatted data
# without a template engine or other plugins.
#
# https://aiohttp.readthedocs.io/en/stable/
# http://jinja.pocoo.org/


from aiohttp import web  # Use the AIO Http Lib
import os
import aiohttp_jinja2
import jinja2
import datetime

# Microservices deployed as containers are ephemeral, they come and go quickly.
# One option for passing configuration data to the container is via environment variables.
#  Here we are assiging several variables but also applying default values
PRESENTER = os.environ.get('PRESENTER', "Don't know")
ENV = os.environ.get('ENVIRONMENT', "unknown")
STATIC = os.environ.get('STATIC', 'http://localhost:8081')


# Handle a request mapped from the URL below and process it through the template
# Typically every URL will get a function to handle the execution.
@aiohttp_jinja2.template('./templates/index.jinja2')
async def handle(request):
    now = datetime.datetime.now()
    return {"static_host": STATIC, "presenter": PRESENTER, "date": now.strftime("%Y %m %d | %H:%M:%S"), "env": ENV}


# Initialize the base web application, this sets up the aiohttp's web server
app = web.Application()
# tell the template system where to look for templates
aiohttp_jinja2.setup(app, loader=jinja2.FileSystemLoader(''))

# Add URL's the the application router. these can be GET PUSH or others as needed.
app.router.add_get('/index.html', handle)  # Configure a URL
app.router.add_get('/', handle)  # Configure another URL
app.router.add_get('/demo.html', handle)  # Configure another URL

# Loop and listen for connections
web.run_app(app)
