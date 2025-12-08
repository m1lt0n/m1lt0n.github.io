---
title: 'How to use nil channels in Go ?'
published: 2020-08-23 09:41:55 +0300
tags: ['go', 'channels']
---

Channels is an integral part of Go applications. They are typed conduits that allow communication between different parts of an application. Recently, I came across an interesting pattern which involves the use of nil channels. But what exactly is a nil channel? Simply a channel that has been assigned a value of nil. Nil channels have a few interesting behaviours:

- Sends to them block forever
- Receives from them block forever
- Closing them leads to panic

Nevertheless, nil channels are useful in some contexts. Let's see a simple example:

```go showLineNumbers
package main

import (
  "fmt"
)

func sendTo(c chan<- int, iter int) {
  for i := 0; i <= iter; i++ {
    c <- i
  }

  close(c)
}

func main() {
  ch1 := make(chan int)
  ch2 := make(chan int)

  go sendTo(ch1, 5)
  go sendTo(ch2, 10)

  for {
    select {
      case x := <-ch1:
        fmt.Println("Channel 1 sent", x)
      case y := <-ch2:
        fmt.Println("Channel 2 sent", y)
    }
  }
}
```

In the example above, we create 2 channels, send a few values to them and then close them. The main function reads the values as they come. Running this code will print out the values we sent to the channels and then will go on printing zero values indefinitely. Why? Because when a channel is closed, receiving from it does not block and immediately returns the zero value of the channel's type (in this case the integer zero).

This may or may not be an acceptable behaviour for our code. Let's assume that zero is one of the valid values that can be sent to the channels. How would we know that it does not come from a closed channel instead? That's an easy thing to do, as receiving from a channel returns 2 values: the received value and whether the channel is still open. Let's make some changes to our for loop:

```go
  for {
    select {
      case x, ok := <-ch1:
        if !ok {
          fmt.Println("Channel 1 is closed")
        } else {
          fmt.Println("Channel 1 sent", x)
        }
      case y, ok := <-ch2:
        if !ok {
          fmt.Println("Channel 2 is closed")
        } else {
          fmt.Println("Channel 2 sent", y)
        }
    }
  }
}
```

With the changes we made above, we are able to distinguish between legitimate zero values coming from an open channel and the zero values of the closed ones. Nevertheless, when we run this code, we see that the closed channel messages are printed indefinitely. It would be nice to ignore the closed channels in our loop and instead of an inifinite busy loop have the program exit when all messages have been received. Nil channels to the rescue! Let's see the code and we will explain it:

```go
  for ch1 != nil || ch2 != nil {
    select {
      case x, ok := <-ch1:
        if !ok {
          fmt.Println("Channel 1 is closed")
          ch1 = nil
        } else {
          fmt.Println("Channel 1 sent", x)
        }
      case y, ok := <-ch2:
        if !ok {
          fmt.Println("Channel 2 is closed")
          ch2 = nil
        } else {
          fmt.Println("Channel 2 sent", y)
        }
    }
  }
}
```

As you can see, we set closed channels to nil. But this is not enough, we make the infinite for loop run conditionally if there are no nil channels, too. This leads to the expected behaviour: reading all messages from each channel and then normally terminating the program. If we had kept the for loop as an unconditional loop, we would end up with deadlock, since the receive from any of the nil channels would block for ever.

Having said that, if all we want is to terminate the program after receiving all values from the channels, we could just have some boolean flag for each channel (e.g. isOpen) and have our for loop check: `isChannel1Open || isChannel2Open`. But this would just solve one of the issues (terminating the program). The loop would continue to be a busy loop, as it would for ever receive from the closed channel(s).

That's all for now!
