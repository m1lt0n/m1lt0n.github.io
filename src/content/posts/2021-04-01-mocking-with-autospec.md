---
title: 'Mocking in python with autospec'
published: 2021-04-01 08:00:00 +0300
tags: ['python', 'unittest', 'mock', 'autospec']
---

Mocking and mocks are really useful when writing tests, as they allow isolating the test target from its dependencies, leading to less fragile tests.

By using mocks in your unit tests, you ensure that when a test fails, it will be because something change in the implementation of the tests' target. Having said that, though, the way mocks are setup may lead to tests that don't fail while they should! How can that happen?

Let's see an example. Let's assume that we have a calculator which depends on a multiplier and an adder (let's assume that our calculator just supports only adding and multiplying numbers).

```python
# File location: calc/calculator.py (cacl is a package)

class Adder:
    def add(self, x, y):
        return x + y


class Multiplier:
    def multiply(self, x, y):
        return x * y


class Calculator:
    def __init__(self, adder, multiplier):
        self._adder = adder
        self._multiplier = multiplier
        self._result = 0

    def clear(self):
        self._result = 0
        return self._result

    def perform(self, operator, num):
        if operator == '*':
            self._result = self._multiplier.multiply(self._result, num)
        elif operator == '+':
            self._result = self._adder.add(self._result, num)

        return self._result
```

Let's now say that we want to write some unit tests for the calculator (below I assume that we're using pytest):

```python
# File location: tests/test_calculator.py (tests is a package)

from unittest import mock
from calc.calculator import Calculator

class TestCalculator:
    def test_addition_works_properly(self):
        adder = mock.Mock()
        adder.add.return_value = 5

        calculator = Calculator(adder, mock.Mock())
        result = calculator.perform('+', 5)

        adder.add.assert_called_once_with(0, 5)
        assert result == 5
```

The test above passes and everything is well, right? Definitely not! Mocking the adder and having it return a specific value is common, but the signature of the add function can diverge from the actual code to the tests and the tests wouldn't notice that. To verify this, let's change the calculator's perform method:

```python
# The rest of the calculator.py file is omitted.

def perform(self, operator, num):
    if operator == '*':
        self._result = self._multiplier.multiply(self._result, num)
    elif operator == '+':
        self._result = self._adder.add(self._result)

    return self._result
```

We have removed the second argument from the call to the adder. When we run our tests, they are green and happy, while the code is actually broken as you can verify by jumping in a repl and using the real adder and multiplier with the calculator.

How can we fix this issue? Mock's autospec comes to the rescue! mock modules create_autospec function creates a mock object using another object as a spec. Any functions called on the mock are checked for their signature. This is great because the mock now depends on the actual implementation and we'll get an error if something changes in the implementation and the calculator doesn't honor the signature of its dependencies.

Let's change the test:

```python
# File location: tests/test_calculator.py (tests is a package)

from unittest import mock
from calc.calculator import Calculator

# The rest of the test_calculator.py file is omitted.

def test_addition_works_properly(self):
    adder = mock.create_autospec(Adder)
    adder.add.return_value = 5
```

Running the test now reveals the error in our Calculator's implementation: `TypeError: missing a required argument: 'y'`. That's great! Now, we can go back to our code and fix our perform method's bug. Once we do that, the tests are again green.

To find out more about autospec, check out <a href="https://docs.python.org/3/library/unittest.mock.html#unittest.mock.create_autospec" target="_blank" rel="noopener nofollow">the official documentation</a>.

That's all for now folks!
