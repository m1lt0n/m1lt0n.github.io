---
title: 'Quick tip: Task execution order changes based on module type'
published: 2025-12-23
tags: ['node', 'javascript', 'event loop']
---

I was recently reading a bit about the internals of the Nodejs event loop (check out the <a href="https://nodejs.org/en/learn/asynchronous-work/event-loop-timers-and-nexttick#what-is-the-event-loop" target="_blank" rel="noopener nofollow">official docs</a>). I won't get into the details of how the event loop works, but the official docs linked above and a nice blog post (check it out <a href="https://medium.com/@ignatovich.dm/the-javascript-event-loop-explained-with-examples-d8f7ddf0861d" target="_blank" rel="noopener nofollow">here</a>) provide a high-level explanation of the main concepts and the way the event loop works.

I wanted to share an example of a subtle difference in the execution order of different things (macrotasks, microtasks, etc) that I found interesting. Here is the code:

```javascript showLineNumbers
const { createHash } = require('node:crypto')

function main() {
  console.log('In main function (1)')

  // A macro task
  setTimeout(() => {
    console.log('In timeout')
  }, 0)

  // A promise (micro task)
  const p = new Promise((resolve, _) => {
    const secret = createHash('sha256').update('supersecret').digest()
    resolve(secret)
  })
  p.then((_) => console.log('Promise resolved'))

  // Next tick callbacks
  process.nextTick(() => {
    console.log('Next tick')
  })

  process.nextTick(() => {
    console.log('Another Next tick callback')
  })

  console.log('In main function (2)')
}

main()
```

The output of this code when running `node <filename.js>` is:

```bash
In main function (1)
In main function (2)
Next tick
Another Next tick callback
Promise resolved
In timeout
```

This is what I expected, too: the main function is executed, then next tick callbacks (find out more about it <a href="https://nodejs.org/en/learn/asynchronous-work/understanding-processnexttick" target="_blank" rel="noopener nofollow">here</a>), the promise callbacks and finally the timeout callback. In general, the order of execution is: the oldest macrotask in the macrotask queue, then next tick callbacks, then all the microtasks, then the oldest macrotask and so on.

So far, so good. Let's now make a small change and switch to ES modules instead of commonjs. We'll only need to change the first line of the script to this:

```javascript
import { createHash } from 'node:crypto'
```

When we run the script again, the output changes to this:

```bash
In main function (1)
In main function (2)
Promise resolved
Next tick
Another Next tick callback
In timeout
```

Promise callbacks get executed first and next tick callbacks afterwards! Why is that? Searching for an answer, the official docs explain it very well (check the <a href="https://nodejs.org/api/process.html#when-to-use-queuemicrotask-vs-processnexttick" target="_blank" rel="noopener nofollow">documentation</a> for more details):

<blockquote>So in CJS modules process.nextTick() callbacks are always run before queueMicrotask() ones. However since ESM modules are processed already as part of the microtask queue, there queueMicrotask() callbacks are always executed before process.nextTick() ones since Node.js is already in the process of draining the microtask queue.</blockquote>
