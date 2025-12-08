---
title: 'Quick tip: Easily identify failing parametrized test in pytest with pytest.param'
published: 2021-05-03 08:00:00 +0300
tags: ['python', 'pytest', 'parametrize']
---

Pytest is a great tool for writing and running tests in python. One of the features I find myself using a lot is parametrized tests.

Parametrization of arguments e.g. when unit testing a function is great, as it keeps the code of the tests short and you can test a lot of different inputs that will give you more confidence regarding how your code works with different inputs. By the way, a great way to get different sets of inputs is to use property testing (e.g. with a tool like `hypothesis`).

Let's assume we have a calculator module, which includes an add method. As you can see below, the add function has a bug when the first number is negative.

```python
# File location: calc/calculator.py (cacl is a package)

def add(x, y):
    if x < 0:
        return x * y

    return x + y
```

Let's assume that our test suite uses parametrization:

```python
# File location: calc/test_calculator.py (cacl is a package)

import pytest
from calculator import add


@pytest.mark.parametrize(
    'x,y,result',
    [
        (1, 2, 3),
        (-3, 4, 1)
    ]
)
def test_add(x, y, result):
    assert add(x, y) == result
```

When running the tests, we'll get an assertion error:

```bash
======================================== short test summary info ========================================
FAILED test_calculator.py::test_add[-3-4-1] - assert -12 == 1
```

We see that the test fails when the arguments passed to it are (-3, 4, 1). Imagine testing other functions (or even http endpoints) with parametrized tests, wouldn't some context be helpful, especially to other people?

Here is where `pytest.param` comes in handy. Let's change our test's code:

```python
# File location: calc/test_calculator.py (cacl is a package)

import pytest
from calculator import add


@pytest.mark.parametrize(
    'x,y,result',
    [
        pytest.param(1, 2, 3, id='Addition of positive numbers'),
        pytest.param(-3, 4, 1, id='Addition of positive and negative numbers')
    ]
)
def test_add(x, y, result):
    assert add(x, y) == result
```

Let's see the test failure when we run this updated version of the test:

```bash
======================================== short test summary info ========================================
FAILED test_calculator.py::test_add[Addition of a positive number to a negative one] - assert -12 == 1

```

As you can see, with a simple change (using pytest.param and providing an id), we get much more context about what the parametrized test is about.

That's all for now folks!
