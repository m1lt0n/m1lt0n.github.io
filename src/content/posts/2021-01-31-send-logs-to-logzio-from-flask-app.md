---
title: 'Send logs to logz.io from your Flask application'
published: 2021-01-31 09:00:00 +0300
tags: ['python', 'flask', 'logzio', 'logs']
---

Logging is of great importance for web applications, both while in your local environment and for production applications. Logs can be analyzed and reveal issues and the can be used to debug applications.

In this post, we'll see how to easily send logs from a flask application to <a href="https://logz.io" target="_blank" rel="noopener nofollow">logz.io</a>. Logz.io has a quite generous free tier (1GB daily data volume), so feel free to register for a free account and run the code of this post for your own account.

So, let's build our flask application first. We start by installing the dependencies:

```bash
mkdir sampleapp
cd sampleapp
python -m venv env

pip install flask
pip install python-dotenv
```

Now, lets build our sample application:

```python
# File: sampleapp/app/__init__.py
from flask import Flask

app = Flask(__name__)
app.config.from_object('app.config.Config')

@app.route('/')
def root():
    app.logger.warning('This is a warning')

    return {'message': 'Hello, world!'}


# File: sampleapp/app/config.py
import os

class Config:
    LOGZIO_URL = os.environ.get('LOGZIO_URL')
    LOGZIO_TOKEN = os.environ.get('LOGZIO_TOKEN')
```

So, in the code above, we create a mini application with just one endpoint. Within the route's code, we log a warning message. The second file (config) holds the configuration of the application.

This file includes only our logz.io specific configuration, but in a real-world application it will probably have a lot more attributes. Config reads its values from environment variables. So, in order to fill Config's attributes, we'll need a .env file like this:

```python
# File: samplapp/.env
LOGZIO_URL=listener.logz.io
LOGZIO_TOKEN='the token from Settings > General Account settings section'
```

Ok! We now have our simple flask app and we want to send its logs to logz.io, too. The great news is that logz.io provides a logging handler for this purpose. We can add this handler in the application logger or in the root logger (in order to send all loggers' messages to logz.io) and we're done!

First, let's install the new dependency:

```bash
pip install logzio-python-handler
```

Then, we can create a simple flask extension to use with our app:

```python
# File: sampleapp/app/flask_logzio.py
import logging
from logzio.handler import LogzioHandler


class FlaskLogzio:
    def __init__(self, app=None):
        self.app = app
        if app is not None:
            self.init_app(app)

    def init_app(self, app):
            token = app.config.get('LOGZIO_TOKEN')
            assert token is not None

            url = app.config.setdefault('LOGZIO_URL', 'listener.logz.io')

            logz_handler = LogzioHandler(token, url=f'https://{url}:8071')
            logging.getLogger().addHandler(logz_handler)
```

This simple extension reads the token and logz.io endpoint/url from the application's configuration, creates the handler that comes with the newly added dependency and we add the handler to the root logger. If you want to send only logs that you create via the application logger, the handler can be attached to `app.logger` instead. Adding it to the root logger, will send all your logs to logz.io (e.g. sqlalchemy, application and any other library's logs).

Now, the only thing remaining is to add the extension to our app:

```python
from flask import Flask
from app.flask_logzio import FlaskLogzio

app = Flask(__name__)
app.config.from_object('app.config.Config')
FlaskLogzio(app)


@app.route('/')
def root():
    app.logger.warning('This is a warning')

    return {'message': 'Hello, world!'}
```

That's it! Now, all your logs will end up in logz.io, too. An important note about the configuration values needed for logz.io: you can get the token from the logz.io dashboard under Settings > General (section Account settings -> token) and use it as the value of `LOGZIO_TOKEN`. Depending on the aws region you selected for storing your data, you may need to set the `LOGZIO_URL` environment variable. Find out the different values for the url <a href="https://docs.logz.io/user-guide/log-shipping/listener-ip-addresses.html" target="_blank" rel="noopener nofollow">on this page</a>.

That's it for now!
