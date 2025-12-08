---
title: 'Cleanup functions using the atexit module'
published: 2022-04-30 16:00:00 +0300
tags: ['python', 'atexit']
---

Recently, I was going through the documentation and codebase of a python package (specifically kafka-python) and was curious about how cleaning up resources and sending pending messages (messages that are still in-memory and haven't been sent to the Kafka brokers) from a Kafka producer.

What I found is that the specific (and several other libraries) are using the `atexit` (built-in) python module (check out the <a href="https://docs.python.org/3/library/atexit.html" target="_blank" rel="noopener nofollow">official documentation</a>).

The `atexit` module allows you to register handlers (functions) that run automatically upon interpreter termination. As the official documentation mentions:

> The functions registered are not called when the program is killed by a signal not handled by Python, when a Python fatal internal error is detected, or when os.\_exit() is called

This means that the handlers registered with atexit run on normal termination of a python script (e.g. after `sys.exit(0)`), but not when the interpreter crashes, or a signal that is not handled by python (e.g. via a SIGTERM by doing `kill -15 script_pid` - for this we can use the built-in module `signal`, which we'll see in a future post - stay tuned :-) ). `os._exit` is is similar to `sys.exit`, but does not run cleanup handlers.

## Registering cleanup functions

So, let's see how we can use `atexit` in practice:

```python showLineNumbers
import atexit
import time
import sys

def exit_handler():
  print('Message from exit handler...')

atexit.register(exit_handler)

print('Will sleep for 1 second...')
time.sleep(1)
```

At line 5, we create the handler (which, in this simple example, just prints out a message), and we register it with `atexit.register`. Alternatively, we can use `atexit.register` as a decorator like that:

```python
@atexit.register
def exit_handler():
  print('Message from exit handler...')
```

If we run the script, we'll get the following output:

```bash
Will sleep for 1 second...
Message from exit handler...
```

Once the script ends (after printing a message and sleeping for 1 second), the atexit handler kicks in and prints its message. Multiple handlers can be registered and upon script termination they will run in reverse order. Here's an example:

```python showLineNumbers
import atexit
import time
import sys

@atexit.register
def exit_handler_1():
  print('Message from exit handler 1...')

@atexit.register
def exit_handler_2():
  print('Message from exit handler 2...')

print('Will sleep for 1 second...')
time.sleep(1)
```

Running the updated script, we'll get the following output:

```bash
Will sleep for 1 second...
Message from exit handler 2...
Message from exit handler 1...
```

## Unregistering a cleanup function

Building on top of the example above, we can unregister a cleanup function after it's been registered:

```python showLineNumbers
import atexit
import time
import sys

@atexit.register
def exit_handler():
  print('Message from exit handler 1...')

atexit.unregister(exit_handler)

print('Will sleep for 1 second...')
time.sleep(1)
```

Running the updated script, we'll get the following output (in which you can see that the cleanup function that has been unregistered doesn't run at all):

```bash
Will sleep for 1 second...
```

Real-world examples of cleanup functions using atexit can be found in various libraries (e.g. check out kafka-python's producer implementation) and usually are doing some kind of cleanup (e.g. closing Kafka producers, sending pending log messages that are stored in-memory until they reach a batch size or every X amount of time, etc).

That's all for now!
