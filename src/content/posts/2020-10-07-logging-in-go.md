---
title: 'Logging in go'
published: 2020-10-07 09:00:00 +0300
tags: ['logging', 'go']
---

It is common knowledge that logging is super important. It is necessary for debugging purposes on your local environment or for tracing some weird behavior in production. There are several pieces of information that are important when using logging.

Specifically:

- **log level**: the kind of log message (informational, warning, error etc)
- **timestamp**: when something happened (usually down to the second or millisecond)
- **message**: description of the event being logged (usually providing some context and data useful for debugging)

An example log message could be something like that:

```bash
[INFO] 2020/10/07 09:39:50.538551 Created user with ID 5
```

### The log package

Go has a simple logging package (package `log` - find out more in the <a href="https://golang.org/pkg/log/" rel="noopener nofollow" target="_blank">documentation</a>). The log package defines a logger and some helper functions that utilize a "standard logger", which is a logger with predefined output (the standard error).

Let's see all that in action. First, the helper functions that utilize the "standard logger":

```go
package main

import (
	"log"
)

func main() {
	log.Println("test")
}
```

Super simple. The code above uses the standard logger and prints the message (along with a date and time) to the standard error. This is very easy to use and quite useful for local development, as you can print out statements (yes, sometimes I resort to print debugging :) ).

The log package defines a constructor for loggers. Its arguments are:

- **output**: defines where the log messages will be written - implements the Writer interface
- **prefix**: a prefix to add in all log messages
- **flags**: some flags that specify the rest of the information added in the log message (mainly timestamp related)

Here is an example creating a custom logger:

```go
package main

import (
	"log"
)

func main() {
	logger := log.New(os.Stderr, "[MAIN] ", log.Ldate|log.Lmicroseconds)

	logger.Println("Logging something...")
	// logger.Fatalln("Something is wrong")
	// logger.Panicln("panic!")
}
```

As you can see in the example above, we create a logger that logs to the standard error, add a prefix to each log message and set the flags to display the date and time (down to the microsecond) of the message. The logger has several methods defined. The most important of them are Print/Fatal and Panic (and their variants e.g. Printf, Println). Print just writes the log message to output, Fatal writes the log message and then calls `os.Exit(1)` and Panic outputs the message and then panics.

Since the logger accepts a Writer, it is very easy to implement loggers that write to the console, files, or something else. Let's see a more complex example:

```go
package main

import (
	"io"
	"log"
	"os"
)

func main() {
	file, err := os.OpenFile("log.txt", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0600)

	if err != nil {
		os.Exit(1)
	}

	writer := io.MultiWriter(os.Stderr, file)
	logger := log.New(writer, "[MAIN] ", log.Ldate|log.Lmicroseconds)

	logger.Println("Logging something...")
	logger.Println("Logging something else...")
}
```

Let's go through the above code. Initially, we open a "log.txt" file (the flags we set allow us to write to the file, create the file if it does not exist and append to the file when writing data to it). Then, we create a MultiWriter. A MultiWriter implements the writer interface and writes everything to each of the Writers we provide when constructing it. Since it implements the Writer interface, we can use it with log.

If you run this code, you will see the log messages both outputted in the standard error and added to the "log.txt" file at the same time. Cool!

As you can see, the `log` package is quite easy to use and flexible. Nevertheless, logging needs often exceed what the standard library's logger has to offer. For this reason, there are several logging libraries that solve the most common use cases. It is better to not reinvent the wheel and use one of those.

Some of the most popular logging libraries are:

- **logrus**: find out more <a href="https://github.com/sirupsen/logrus" rel="noopener nofollow" target="_blank">here</a>
- **zap**: find out more <a href="https://github.com/uber-go/zap" rel="noopener nofollow" target="_blank">here</a>
- **zerolog**: find out more <a href="https://github.com/rs/zerolog" rel="noopener nofollow" target="_blank">here</a>

We will examine some of those loggers in a future post. That's all for now!
