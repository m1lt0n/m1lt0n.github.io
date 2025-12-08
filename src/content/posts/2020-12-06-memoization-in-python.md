---
title: 'Memoization in python'
published: 2020-12-06 10:00:00 +0300
tags: ['memoization', 'python']
---

Memoization is loosely defined as an optimization technique that is usually applied on functions that are quite expensive to run.

Usually, memoization is useful with recursive functions where their result depends on the same function's result with a different set of arguments. Memoization caches the intermediate results of these functions and gets their value from the cache. This leads to less function calls and a considerable performance improvement.

A good example of a recursive function that can benefit from memoization is a function that returns items of the fibonacci sequence. A simple implementation is:

```python
import sys

def fib(n):
    if n < 2:
        return 1

    return fib(n - 1) + fib(n - 2)

if __name__ == '__main__':
    print(fib(int(sys.argv[1]))

```

The implementation is super simple. In terms of performance though, it is terrible. Why? Because as n increases, the number of function calls that calculate the intermediate results increases quite significantly. For example, if we set n=30, the fib function is called 2.7 million times! You can see that yourself by using a profiler (e.g. `python -m cProfile fib.py 30`). For n=35, the number of function calls jump to 29.9 millions!

How can we improve the performance of the fib function? Caching is a good strategy in this case, as once an intermediate result is calculated, it can be reused and we can save a lot of function calls. Here is a simple memo function we can use to decorate the fib function:

```python
def memo(func):
    results = {}

    def wrapper(n):
        if n in results:
            return results[n]

        results[n] = func(n)
        return results[n]

    return wrapper


@memo
def fib(n):
    if n < 2:
        return 1

    return fib(n - 1) + fib(n - 2)

if __name__ == '__main__':
    import sys
    print(fib(int(sys.argv[1])))
```

The decorator is quite simple. It checks if the result is available for a specific n and, if not, it calculates it, stores it in the cache and returns it. If we run the profiler again (`python -m cProfile fib.py 30`), the number of function calls drops to 90! About 30 for the fib function and another 60 for the memo wrapper function. That's a huge improvement!

Is there a better way? Yes. The standard library has a caching mechanism available. The `functools` module has an lru_cache function that can be used to decorate functions and cache their results. Here is how it works:

```python
from functools import lru_cache

@lru_cache
def fib(n):
    if n < 2:
        return 1

    return fib(n - 1) + fib(n - 2)

if __name__ == '__main__':
    import sys
    print(fib(int(sys.argv[1])))
```

That's it! The `lru_cache` function can also be customized (e.g. set the size of the cache). For more information, check lru_cache in the <a href="https://docs.python.org/3/library/functools.html" target="_blank" rel="noopener nofollow">functools</a> documentation.

That's all for now!
