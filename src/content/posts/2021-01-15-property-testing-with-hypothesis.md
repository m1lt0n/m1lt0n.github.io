---
title: 'Property testing with hypothesis'
published: 2021-01-15 08:00:00 +0300
tags: ['testing', 'python']
---

Testing is a huge field and takes a significant amount of time to master. There are several types of tests, like unit, functional, integration, end-to-end (e2e) test and each of those types has its own place in the testing.

There is an interesting concept of the testing pyramid which helps with understanding the need for different kinds of tests, as well as their benefits. Check out these posts for more information:

- <a href="https://www.testim.io/blog/test-automation-pyramid-a-simple-strategy-for-your-tests/" target="_blank" rel="nofollow noopener">Test Automation Pyramid: A Simple Strategy for Your Tests</a>
- <a href="https://martinfowler.com/bliki/TestPyramid.html" target="_blank" rel="nofollow noopener">Test Pyramid by Martin Fowler</a>

In the context of unit tests (mainly), property based testing is a technique for building tests in a way that when these tests are fuzzed, issues of the code can be identified (e.g. edge cases not taken into account).

In several cases, when we write tests we test the different branches of our code (e.g. by parametrizing our tests in order to check for different inputs that cause different parts of the code to be executed). There are cases though where the inputs we provided to our tests might not be adequate to cover all cases and we may be ignorant of that.

By using a property based testing, we can reveal these kinds of issues. Thankfully, there are tools to help us :) One of these tools is hypothesis.

Let's assume we want to test this piece of code:

```python
def how_many_times(x, length):
  return length // len(x)
```

Super simple function. Given a string and an integer (the length), we want to see how many times the whole string can fit in this length.

So, let's say we use pytest for writing tests and we have come up with this tests for `how_many_times`:

```python
from how_many_times import how_many_times

def test_how_many_times_with_space_left():
    assert how_many_times('test', 10) == 2

def test_how_many_times_with_no_space_left():
    assert how_many_times('test', 16) == 4
```

We are happy that we always get an integer and the division works properly, right? Let's introduce hypothesis:

```python
from how_many_times import how_many_times
from hypothesis import given
from hypothesis.strategies import text, none

@given(text() | none())
def test_how_many_times_fuzzy(s):
    assert how_many_times(s, 10) == 10 // len(s)
```

Let's explain the code a bit. Hypothesis helps us provide input to our tests (using given) and has a lot of prebuilt strategies that generate this input. In the example above, we used the `text` and `none` strategies. Text generates random strings and none provides None as the input. Running this test reveals 2 issues with our code:

1. We do not handle empty strings (division by zero error)
2. We do not handle None as an input (None does not have a len method)

Now, if we absolutely know that we won't be passing None or empty strings to the function, we may be covered by our initial 2 tests. But hypothesis has identified issues in the code that might have slipped our attention.

When I use hypothesis in my code, I tend to do it in 2 ways: either write tests that become part of the test suite or I write tests, identify the edge cases and test for those cases explicitly.

For example, after seeing the results of the property based test, I might end up change my initial tests to something like this:

```python
import pytest
from how_many_times import how_many_times

def test_how_many_times_with_space_left():
    assert how_many_times('test', 10) == 2

def test_how_many_times_with_no_space_left():
    assert how_many_times('test', 16) == 4

@pytest.mark.parametrize(
    'input,exc',
    [
        ('', ZeroDivisionError),
        (None, TypeError)
    ]
)
def test_how_many_times_exceptions(input, exc):
    with pytest.raises(exc):
        how_many_times(input, 10)
```

We have just scratched the surface of property based testing, but I hope the benefit of it is very clear even with this small example. Hypothesis has lots of features that we haven't covered here. You can find out more about hypothesis <a href="https://hypothesis.readthedocs.io/en/latest/index.html" target="_blank" rel="noopener nofollow">here</a>.

That's all for now!
