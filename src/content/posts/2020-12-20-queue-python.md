---
title: 'Queues in python'
published: 2020-12-20 09:00:00 +0300
tags: ['queues', 'data', 'python']
---

Queues are a really useful data structure that are being frequently used both in application code and are also utilized by libraries. In this post, we'll see what they are, how they work and some implementations of them in the Python standard library.

A queue is a collection of items. How does this differ from a list? Queues are FIFO (first-in-first-out) data structures. This means that when an item is added to the queue, it is appended after the last item of the queue, while when popping/removing an item from the queue, it is removed from the beginning of the queue. This means that the items that were added first to the queue are removed first, too. Find out more about queues in <a href="https://en.wikipedia.org/wiki/Queue_(abstract_data_type)#:~:text=In%20computer%20science%2C%20a%20queue,other%20end%20of%20the%20sequence." target="_blank" rel="noopener nofollow">wikipedia</a>.

Let's see a simple implementation of a queue (in Python):

```python
class MyQueue:
    def __init__(self):
        self.items = []

    def enqueue(self, item):
        self.items.append(item)

    def dequeue(self):
        return self.items.pop(0)
```

:::note
The implementation above is not thread safe.
:::

`MyQueue` internally uses a list to store the data of the queue. When we enqueue an item, we append it to the end of the list and when we dequeue and item, we remove it from the start of the list.

That's it. Where would a queue structure be useful? Queues are common in several scenarios. Here are a couple of examples:

- In background job processing tools. A job is received by the tool. These jobs can be stored in a queue and then be processed in the order they arrived.
- Printers use queues so that they print the documents that are sent to them in the order they are sent

The Python standard library has already implemented queues and we don't need our custom implementation (Yes!!). The `queue` module includes an implementation of a FIFO queue and also a priority queue. A priority queue is a queue where a priority is set when adding an item in it and the `dequeue` operation returns the item with the highest priority (instead of the first item appended to the queue). I'll prepare a separate post for priority queues in the future :)

Let's see an example of the queue module:

```python
from queue import Queue

q = Queue()
q.put(1)
q.put(2)
q.put(3)
q.put(4)

while not q.empty():
    print(q.get())
```

In the example above, we add a few items in the queue and remove all of them one by one. This works as the custom `MyQueue` implementation, but has a few extra benefits:

- Queue is thread safe. It is synchronized so that multiple consumers and producers can use it. This means that we can share and operate the queue between multiple threads.
- Getting an item from the queue blocks when the queue is empty. Also, setting the maxsize of the Queue (e.g. initializing it as Queue(maxsize=5)) allows us to block when inserting an item in the queue.

That's all for now!
