---
title: 'How to time out requests in your go API'
published: 2020-08-28 10:00:00 +0300
tags: ['go', 'http', 'timeout']
---

When building an API (or other kinds of applications, to be frank), sometimes it is useful to set some constraints to the task being carried out (e.g. handling an http request to some of your API's endpoints).

A common constraint is response time. Why would timing out from your server be useful? Because not all clients of your API will set timeouts in their requests, leading to their own applications or scripts waiting endlessly for a response in case your server is taking too long to respond.

Let's assume you have build a super simple greeting API:

```go
package main

import (
  "fmt"
  "net/http"
  "log"
  "time"
)

func hello(w http.ResponseWriter, r *http.Request) {
  time.Sleep(1 * time.Second)
  fmt.Fprint(w, "Hello there!")
}

func main() {
  http.HandleFunc("/hello", hello)

  log.Fatal(http.ListenAndServe(":8080", nil))
}
```

As you can see, we have added a delay of 5 seconds in our handler to simulate a quite long response time. Real-world scenarios might include calling an external API, executing some database queries etc. Clients of our API will have to wait for a long time, leading to poor experience in their applications or scripts (unless they have explicitly set a timeout in their calls to our API).

It would be great to discover requests that take long to run and respond with a timeout to the clients ourselves (and perhaps do some other things like instrumentation, logging etc in order to uncover those slow responses).

There are several ways to achieve this.

### net/http TimeoutHandler

The go standard library includes a `TimeoutHandler` that is suitable for this purpose. Let's see how this works:

```go
// ...

func main() {
  http.Handle("/hello", http.TimeoutHandler(http.HandlerFunc(hello), 100 * time.Millisecond, "server timed out"))

  log.Fatal(http.ListenAndServe(":8080", nil))
}
```

The `http.TimeoutHandler` function creates an `http.Handler`, which runs the original handler and after a specified duration (in our case 100ms), it responds with the message passed in the arguments and a status of 503.

Find out more about `http.TimeoutHandler` in <a href="https://golang.org/pkg/net/http/#TimeoutHandler" target="_blank" rel="noopener nofollow">the standard library documentation</a>.

### Write a custom middleware

There are cases where you might want to do something more involved in case of a timeout. In this case, it is really simple to roll your own middleware that will handle timeouts. Let's see how it can be done:

```go
// ...

func timeOut(handler func(w http.ResponseWriter, r *http.Request), to time.Duration) func(w http.ResponseWriter, r *http.Request) {
  return func(w http.ResponseWriter, r *http.Request) {
    done := make(chan bool)

    go func() {
      handler(w, r)
      done <- true
    }()

    for {
      select {
      case <-time.After(to):
        fmt.Fprint(w, "server timed out!")
        return
      case <-done:
        return
      }
    }
  }
}

func main() {
	http.HandleFunc("/hello", timeOut(hello, 100 * time.Millisecond))
	log.Fatal(http.ListenAndServe(":8080", nil))
}
```

As you can see above, `timeOut` returns a handler function that runs the original handler in a goroutine and then runs a for loop waiting from a message from either the done channel (when the request handling has finished) or from the `time.After` channel, which send a message after 100ms. Since we own the handler code, we can do whatever we want with it (add logging, change the response status or the response itself etc).

A slightly different approach to the `done` channel would be to use a context with a timeout (to find out more about context, read more <a href="https://golang.org/pkg/context/" target="_blank" rel="noopener nofollow">in the go docs</a>). Here it is:

```go
// ...

func timeOut(handler func(w http.ResponseWriter, r *http.Request), to time.Duration) func(w http.ResponseWriter, r *http.Request) {
  return func(w http.ResponseWriter, r *http.Request) {
    ctx, _ := context.WithTimeout(context.Background(), to)

    go handler(w, r)

    for {
      select {
      case <-ctx.Done():
        fmt.Fprint(w, "server timed out!")
        return
      }
    }
  }
}

func main() {
	http.HandleFunc("/hello", timeOut(hello, 100 * time.Millisecond))
	log.Fatal(http.ListenAndServe(":8080", nil))
}
```

Context allows you to manually cancel or set a timeout and you are notified via the `ctx.Done()` channel, which is what we've done here. Not much different than the previous approach, but I'm putting it there in case you prefer doing it this way. We will dedicate a whole new post about context in the future.

**Note**: you should be aware that both the `http.TimeoutHandler` and our custom approach do not terminate the http handler's goroutine (the original handler), they just respond to the client.

That's all for now!
