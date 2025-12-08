---
title: 'SOLID principles: Single responsibility'
published: 2020-11-30 09:00:00 +0300
tags: ['solid', 'theory', 'principles']
---

SOLID is a set of principles that lead to cleaner, more maintenable and extensible code. The first principle is the **Single Responsibility Principle** or SRP.

SRP states that every class should have one and only one reason to change. If we use slightly different terms to describe that, it will be “every class should be doing one thing” or “every class should be responsible for one thing”.

In order to make things clearer, we’ll start with an example. Let’s say we want to build a simple calculator that initially can handle only addition of numbers. And let’s say that we want to print out the result of the addition on the screen.

Here’s a first draft:

```python
class Calculator:
    def __init__(self):
        self.numbers = []

    def add(self, num):
        self.numbers.append(num)

    def result(self):
        print(sum(self.numbers))
```

Looks pretty simple, right? Despite the fact that this code looks simple and is only a few lines long, it violates the single responsibility principle. Is there a quick way to identify that our code violates the SRP? Yes, and it’s a simple one.

We just need to find more than one reasons to change this class. A reason this class would need to change would be if we would like to add multiplication or subtraction in the calculator. But there is another reason, too: if we want to direct the result to another output (e.g. a file), the class would need to change, too. So, our class has 2 reasons to change.

How could we solve this issue? Let’s assume that we want to be able to choose if we want to print the result or save it to a file. so we start coding again:

```python
class Calculator:
    def __init__(self):
        self.numbers = []

    def add(self, num):
        self.numbers.append(num)

    def result(self):
        return sum(self.numbers)

    def output(self):
        print(self.result())

    def save_to_file(filename):
        with open(filename, 'w') as f:
            f.write(self.output())
```

Our code still has 2 responsibilities (calculating the result and outputting it), but we’ve split the result method into 2 methods (result and output) that each is doing just one well-defined thing. Now you may start seeing why we need the single responsibility on the class level. Every time we’ll need a different way to output the result we’d need to touch this class which is a calculator and shouldn’t care about where the result is written, but just on how to get to the result.

So, in the next iteration of our code we will split the 2 responsibilities, by introducing an Output class:

```python
class Calculator:
    def __init__(self):
        self.numbers = []

    def add(self, num):
        self.numbers.append(num)

    def result(self):
        return sum(self.numbers)


class Output:
    def __init__(self, result):
        self.result = result

    def stdout(self):
        print(self.result)

    def save_to_file(filename):
        with open(filename, 'w') as f:
            f.write(str(self.result))
```

Now we have a much cleaner code, as the Calculator is responsible for producing a result, while the Output class is responsible for the different outputs of the result. Of course, our code has become much more verbose, but the benefits of separation of responsibilities are greater than the verbosity of the code. Next time we need to add a new method to Output class, we won’t touch the Calculator code at all! (Note: The code above is violating other principles such as the open/closed principle that we’ll discuss next, but let’s go one step at a time!)

So, in a few words, that’s all about the single responsibility principle. A side-note on the SOLID principles is that you should strive to follow them but as any other set of rules, you can bend them or ignore them if common sense says so. If the code above was never going to change and only those 2 output methods would be needed ever or if the project that we are working on is a very small micro-application with a few dozens of lines, perhaps the refactoring would be an overkill.

That’s all for now!
