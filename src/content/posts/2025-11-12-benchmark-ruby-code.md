---
title: 'How to benchmark your ruby code'
published: 2025-11-12 11:00:00 +0300
tags: ['ruby', 'benchmark']
---

I've recently started a new personal project (a web application), and decided to build it using Ruby on Rails. I'm a big fan of using boring technology to solve problems and, while I've been working with python codebases in the last 5+ years, when I build personal projects, I find that my productivity when using a batteries-included framework increases significantly. And, in my view, there are few frameworks in other languages that have the amount of functionality that Rails offers out of the box.

Anyway, I find myself frequently trying to optimize some code here and there. Ruby has a <a href="https://ruby-doc.org/3.4.1/stdlibs/benchmark/Benchmark.html" tarrget="_blank" rel="noopener nofollow">Benchmark module</a> in its standard library, so, there is no need to install a gem to do that.

The `benchmark` module has some useful methods we can use to measure how long a code block takes to complete. In order to test out the API of the module, let's assume that we have some code that looks like the one below (a simple implementation of a function that returns the nth member of the fibonacci sequence)

```ruby showLineNumbers
def fib(n)
  return 0 if n == 0
  return 1 if n <= 2
  fib(n - 1) + fib(n - 2)
end
```

If n is quite low (eg below 20), calling the function seems to take almost no time to run, but this simple recursive implementation that has no optimizations takes more and more time as n increases. How can we check that?

Let's use the first method of the benchmark module:

```ruby showLineNumbers
require 'benchmark'

def fib(n)
  return 0 if n == 0
  return 1 if n <= 2
  fib(n - 1) + fib(n - 2)
end

1.upto(30) do |i|
    puts "Fib of #{i} = #{Benchmark.measure { fib(i) }}"
end
```

The `measure` method of the module returns a `Benchmark::Tms` instance, which includes measurements of user, system, total and total time to run the block passed to `measure` (if instead of `puts` you inspect the returned value of the `measure` call, you can access those metrics individually). On my laptop, the results are:

```bash
Fib of 1 =   0.000002   0.000001   0.000003 (  0.000003)
Fib of 2 =   0.000000   0.000000   0.000000 (  0.000001)
Fib of 3 =   0.000001   0.000001   0.000002 (  0.000001)
Fib of 4 =   0.000001   0.000000   0.000001 (  0.000001)
Fib of 5 =   0.000000   0.000000   0.000000 (  0.000001)
Fib of 6 =   0.000001   0.000001   0.000002 (  0.000001)
Fib of 7 =   0.000001   0.000001   0.000002 (  0.000001)
Fib of 8 =   0.000001   0.000000   0.000001 (  0.000002)
Fib of 9 =   0.000003   0.000000   0.000003 (  0.000003)
Fib of 10 =   0.000004   0.000000   0.000004 (  0.000004)
Fib of 11 =   0.000006   0.000000   0.000006 (  0.000006)
Fib of 12 =   0.000010   0.000000   0.000010 (  0.000010)
Fib of 13 =   0.000015   0.000000   0.000015 (  0.000015)
Fib of 14 =   0.000025   0.000000   0.000025 (  0.000025)
Fib of 15 =   0.000040   0.000000   0.000040 (  0.000040)
Fib of 16 =   0.000063   0.000000   0.000063 (  0.000063)
Fib of 17 =   0.000102   0.000000   0.000102 (  0.000102)
Fib of 18 =   0.000167   0.000000   0.000167 (  0.000167)
Fib of 19 =   0.000272   0.000000   0.000272 (  0.000275)
Fib of 20 =   0.000435   0.000000   0.000435 (  0.000439)
Fib of 21 =   0.000707   0.000000   0.000707 (  0.000710)
Fib of 22 =   0.001144   0.000000   0.001144 (  0.001147)
Fib of 23 =   0.001847   0.000000   0.001847 (  0.001850)
Fib of 24 =   0.002973   0.000001   0.002974 (  0.002976)
Fib of 25 =   0.004794   0.000005   0.004799 (  0.004802)
Fib of 26 =   0.007879   0.000002   0.007881 (  0.007880)
Fib of 27 =   0.012759   0.000142   0.012901 (  0.012919)
Fib of 28 =   0.020504   0.000038   0.020542 (  0.020541)
Fib of 29 =   0.033211   0.000099   0.033310 (  0.033327)
Fib of 30 =   0.053594   0.000159   0.053753 (  0.053766)
```

As you can see, the time to calculate a number in the sequence is increasing roughtly by 80% compared to the previous value. This is because of the recursive nature of the implementation (fib(5) = fib(4) + fib(3) = fib(3) + fib(2) + fib(2) + fib(1) = fib(2) + fib(1) + ....). In terms of time complexity, this simple recursive implementation is O(2<sup>n</sup>), which is really bad.

If all we want is to have the `fib` method work for numbers up to 30, we may not have to do anything, as after all, it just takes 5ms to get a result. But what if we want to calculate `fib(40)`? On my laptop, this took 6.6 seconds! You can certainly do better than that!

The naive implementation we have does the same job multiple times: `fib(5)` calculates `fib(4)` and `fib(3)` and `fib(4)` in turn calculates `fib(3)` again and `fib(2)`. This seems like a thing caching can optimize. Let's write a better version of the function:

```ruby showLineNumbers
def fib(n)
  return 0 if n == 0
  return 1 if n <= 2
  fib(n - 1) + fib(n - 2)
end

def fib_with_cache(n, cache=[0, 1, 1])
  return cache[n] if n < cache.length
  cache[n] = fib_with_cache(n - 1, cache) + fib_with_cache(n - 2, cache)
end
```

The new `fib_with_cache` method is still recursive, but stores its result in a cache that is passed to the function as an argument (a simple implementation to avoid keeping state elsewhere for now). How does this perform? Let's find out by using another function of the `Benchmark` module: `bm`. With the `bm` method, we can report the measurements for multiple methods and present them nicely to make comparisons easier:

```ruby showLineNumbers
require 'benchmark'

def fib(n)
  return 0 if n == 0
  return 1 if n <= 2
  fib(n - 1) + fib(n - 2)
end

def fib_with_cache(n, cache=[0, 1, 1])
  return cache[n] if n < cache.length
  cache[n] = fib_with_cache(n - 1, cache) + fib_with_cache(n - 2, cache)
end

Benchmark.bm do |x|
  x.report('no cache') { fib(30) }
  x.report('with cache') { fib_with_cache(30) }
```

The result is:

```bash
                user     system      total        real
no cache    0.053590   0.000091   0.053681 (  0.053681)
with cache  0.000005   0.000000   0.000005 (  0.000004)
```

Our new implementation seems to be performing much better. In terms of time complexity, it is now O(n), since the function calls grow linearly (most calls are hitting the cache now and short-circuit the recursion).

Another interesting method of the `Benchmark` module is the `bmbm` method. The difference with `bm` is that it runs the tests twice, trying to eliminate any effects irrelevant to the code that gets measured (eg garbage collections, etc). This is by no means a bulletproof approach to eliminate those side effects, but the results are more reliable compared to `measure` or `bm`. The results from replacing `bm` with `bmbm` in the last code sample are:

```bash
Rehearsal ----------------------------------------------
no cache     6.603449   0.011702   6.615151 (  6.616095)
with cache   0.000019   0.000001   0.000020 (  0.000019)
------------------------------------- total: 6.615171sec

                 user     system      total        real
no cache     6.585420   0.038607   6.624027 (  6.625772)
with cache   0.000008   0.000000   0.000008 (  0.000008)
```

We can ignore the rehearsal and focus on the second set of results for comparing the 2 functions.

There are a couple more methods in the module, but I won't focus on them. One extra thing to note is that there are a few gems that add extra functionality to Benchmark:

**benchmark-ips** (<a href="https://github.com/evanphx/benchmark-ips" target="_blank" rel="noopener nofollow">repository</a>), which calculates the iterations per second, together with some stats (standard deviation mainly). The iterations per second may be a more intuitive metric for you. If so, consider installing the gem and giving it a try. Here is the report of our fibonacci functions:

```bash
ruby 3.4.7 (2025-10-08 revision 7a5688e2a2) +PRISM [arm64-darwin24]
Warming up --------------------------------------
            no cache     1.000 i/100ms
          with cache    32.280k i/100ms
Calculating -------------------------------------
            no cache      0.152 (± 0.0%) i/s     (6.60 s/i) -      1.000 in   6.598878s
          with cache    323.977k (± 0.4%) i/s    (3.09 μs/i) -      1.646M in   5.081562s
```

The interesting bit is the `Calculating` section, where we can see the number of iterations per second for each function, along with their standard deviation). Check out the documentation of the gem for more information on customization and advanced usage.

Finally, an interesting gem is **benchmark-memory** (<a href="https://github.com/michaelherold/benchmark-memory" target="_blank" rel="noopener nofollow">repository</a>), which helps with measuring the memory usage of your code. I won't get into details for this, since we focused on time complexity in this post, but check out the gem!

That's it for now folks! I hope you found this summary of the Benchmark module and related gems useful.
