---
title: 'Reducing memory consumption in ruby with frozen strings'
published: 2020-09-30 09:00:00 +0300
tags: ['ruby', 'memory', 'string']
---

In ruby, lots of times we have to deal with several strings, whether we are working with a rails application and we are building JSON responses, or we have a script that tokenizes and manipulates text. The way we handle strings can have a huge impact in the performance of our applications and scripts, as it might lead to higher memory usage, which, in turn, can lead to more frequent garbage collections that slow down our code.

How can we handle these issues? There are a few ways. Let's see some code that allocates a lot of strings and uses a lot of memory:

```ruby
GC.disable

arr = []
p GC.stat

1_000_000.times do
  arr << "hello"
end

p GC.stat
```

In the script above, we disable garbage collection (find out more about the <a href="https://ruby-doc.org/core-2.7.0/GC.html" target="_blank" rel="noopener nofollow">GC module</a>) and then perform the work we need to do. In our case, we populate an array with 1 million strings, or to be exact 1 million times the string with value "hello". Ruby creates a new instance of a String each time we use the string literal. This means that 1 million objects are being created and this is a waste of memory, since a single instance of "hello" would be fine for this script (since we don't need to perform some operation on every individual item of the array).

We can see that in the output of `GC.stat`. Specifically the `:heap_live_slots` key in the output of `GC.stat`, which returns the number of slots in the Ruby object heap are filled with an object (not free). In my case, this number was around 16,000 objects before populating the array and increased to 1,016,000 afterwards. So, around 1 million objects were created. On my computer, too, the `:count` key of `GC.stat`, which is the total number of garbage collections went from 13 to 23, so there were 10 garbage collections while the script was running.

How can we avoid that? There are several solutions.

### Create a variable to hold the string

The first solution is to assign the "hello" string to a variable outside the loop and use that variable inside the loop:

```ruby
GC.disable

arr = []
p GC.stat

greeting = "hello"

1_000_000.times do
  arr << greeting
end

p GC.stat
```

This script runs faster and the `GC.stat` output reveals that the live slots remained unchanges, as we allocated only one string and reused it. Using this method to reduce memory is easy and can be used, for example in loops (as in our example above), or in web applications that serve JSON, where the keys of the returned resources (e.g. a list of products return from an API) are repeated.

### Freeze the string

A second solution is to freeze the string. When we call freeze on a string literal, it cannot be modified anymore (it becomes immutable). Ruby does not create new objects in this case when it encounters the same string and reuses the first frozen string it created:

```ruby
GC.disable

arr = []
p GC.stat

1_000_000.times do
  arr << "hello".freeze
end

p GC.stat
```

### Frozen string literal comment

Finally, since Ruby 2.3, there is a magic comment that can be used in any file we want to freeze all string literals. It is as simple as that :) You can gradually add this comment to all files, performing the necessary changes (e.g. dup all the strings that are being updated within your code to avoid exceptions of trying to update frozen strings).

This is how it looks:

```ruby
# frozen_string_literal: true

GC.disable

arr = []
p GC.stat

1_000_000.times do
  arr << "hello"
end

p GC.stat
```

The code above has the same effect as calling `freeze` on all strings in the file. The `GC.stat` output confirms that. There is another way to enforce frozen string literals for all the ruby files without adding the comment, just by setting the environment variable RUBYOPT="--enable-frozen-string-literal":

```bash
RUBYOPT="--enable-frozen-string-literal" ruby YOURSCRIPTNAME
```

That's all for now!
