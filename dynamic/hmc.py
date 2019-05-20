from aiohttp import web  # Use the AIO Http Lib

import os
import aiohttp_jinja2
import jinja2
import datetime

PRESENTER = os.environ.get('PRESENTER', "Unknown")
ENV = os.environ.get('ENVIRONMENT', "unknown")
STATIC = os.environ.get('STATIC', "35.230.1.39")


# Handle a request mapped from the URL below and process it through the template
@aiohttp_jinja2.template('./templates/index.jinja2')
async def handle(request):
    now = datetime.datetime.now()
    return {"static_host": STATIC, "presenter": PRESENTER, "date": now.strftime("%Y%m%d%H%M%S"), "env": ENV}


app = web.Application()  # Initialize the base web application
aiohttp_jinja2.setup(app, loader=jinja2.FileSystemLoader(''))  # tell the template system where to look for templates

app.router.add_get('/index.html', handle)  # Configure a URL
app.router.add_get('/', handle)  # Configure a URL

web.run_app(app)  # Loop and listen for connections

