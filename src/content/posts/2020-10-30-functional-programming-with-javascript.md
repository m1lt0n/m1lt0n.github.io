---
title: 'Functional programming with Javascript'
published: 2020-10-30 13:00:00 +0300
tags: ['javascript', 'functional', 'theory']
---

In the past few years, functional programming's popularity has increased and new languages (like elixir or scala) that embrace it have been created. But what exactly is functional programming?

Functional programming is a programming paradigm, like Object Oriented Programming (OOP). It is built around, well, functions :) and specifically around applying and composing functions, heavily utilizing higher order functions and pure functions (functions that are free from side effects).

Fans of functional programming claim that by eliminating side effects and state mutation, the code is easier to reason about, to test and less prone to errors and bugs. Note though, that not all functions can be pure. You have to save a file or add data in a database from time to time :). Side effects are inevitable in any project.

So, let's examine all those buzzwords, see what they mean and what are the benefits of using them.

### Pure functions and referential transparency

A function is pure when it fulfills some criteria. Specifically:

- Given the same arguments, it returns the same result. This means that the function is deterministic and does not depend on state that is external to it
- There are no side effects. This means that the function just calculates a result that it returns and nothing else. No logging to the standard output, no writing to files or databases, no change of external / shared state. Nothing

To better understand pure functions, let's see some examples of pure and impure functions:

```javascript
// Pure. The function just calculates a result from its arguments
function add(x, y) {
  return x + y
}

// Not pure, as the result is not deterministic. The same arguments can lead to a different return value
function randomAdd(x, y) {
  return (x + y) * Math.random()
}

// Not pure as console.log is a side effect
function addAndLog(x, y) {
  let sum = x + y

  console.log(sum)
  return sum
}

let sum = 0

// Not pure, as mutating external state is a side effect
function addToCurrentSum(x, y) {
  sum += x + y
  return sum
}
```

There are some benefits to using pure functions. They are easy to understand and reason about. Unit testing is quite easy, as no setup/teardown steps are required (since there are no side effects). Building thread-safe code becomes easier, too.

Another term that is frequently used and is relevant to pure functions is **referential transparency**. An expression is referentially transparent, if it can be replaced by the value it returns without changing the behaviour of the code. In the sample code above, if we replace the result of `addAndLog(1, 2)` with 3 where the function is called, we have changed the behaviour of the program, as `console.log` is not called. This means that `addAndLog(1, 2)` is not referentially transparent.

### First-class and higher order functions

First-class and higher order functions are essential in functional programming. What is a first-class function? A programming language supports first-class functions when the functions can be treated just like any other variable: it can be assigned to a variable, passed as an argument to another function, can be returned by other functions etc. Examples of languages that support first-class functions are javascript, scala, elixir and python among others.

Here are some examples in javascript:

```javascript
// a function can be assigned to a variable
const add = (x, y) => x + y
const multiply = (x, y) => x * y

function doSomething(func, x, y) {
  return func(x, y)
}

// a function can be passed as an argument
const result = doSomething(add, 1, 2)

// a function can be returned by another function
function add2() {
  return (x) => x + 2
}
```

The last example (`add2`) is an example of a **higher-order** function. Higher order functions are functions that either return another function, or take a function as a argument.

There are several higher order functions in the standard library of javascript. For example, arrays have several methods like `map, reduce, filter` etc:

```javascript
;[1, 2, 3, 4, 5]
  .map((x) => x * 2) // returns [2, 4, 6, 8, 10]
  [(1, 2, 3, 4, 5)].filter((x) => x % 2 === 0) // returns [2, 4]
```

### Recursion

Functional programming in several cases utilizer recursion. Instead of loops, where we imperatively build our code, recursion breaks down the problem into smaller chuncks and a function can call itself recursively. Let's see an example with a factorial function to better understand what recursion is about:

```javascript
// Non-recursive factorial - imperative
function factorial1(n) {
  if (n <= 1) {
    return 1
  }

  let result = 1

  for (let i = 1; i <= n; i++) {
    result *= i
  }

  return result
}

// Recursive factorial - declarative
function factorial2(n) {
  if (n <= 1) {
    return 1
  }

  return n * factorial(n - 1)
}
```

As we can see above, `factorial2` calls itself several times, until the base case (n <= 1) is reached. It is a classic example of recursion. As you can see, the code of the recursive factorial is shorter and (in my view), easier to understand.

### Immutability

A variable is said to be immutable when it cannot be changed, it cannot be mutated. For example:

```javascript
const x = 1
```

`x` is immutable as it is a primitive value declared a const. We have to be careful, though, as constants that hold an object cannot be reassigned, but the object itself can be mutated:

```javascript
const wallet = { owner: 'Pantelis', money: 100 }

wallet = 5 // this cannot be done
wallet.owner = 'John' // this, on the other hand, is perfectly fine
```

Even when working with objects, immutability is an important concept, as it can make our code less error-prone. For example, let's assume that we withdraw money from our bank account and put them in our wallet. A function `addToWallet` could be written like this:

```javascript
const wallet = { owner: 'Pantelis', money: 100 }

const addToWallet = (wallet, amount) => {
  wallet.money += amount
}

addToWallet(wallet, amount)
```

The code above mutates the wallet and passing objects as arguments to several functions in several places can for sure hurt the readability of code. The flow of information and the sources of mutation are all over the place and the code becomes unpredictable in many cases. How would an immutable version of the `addToWallet` function look like?

```javascript
const wallet = { owner: 'Pantelis', money: 100 }

const addToWallet = (wallet, amount) => {
  return {
    ...wallet,
    money: wallet.money + amount,
  }
}

const newWallet = addToWallet(wallet, amount)
```

In this version, the original wallet is not mutated, but a copy of the wallet is returned (note: a shallow copy) that has the updated money attribute. This has the benefit of letting us (if a function makes multiple changes to an object) just replace the old instance of the object with the new one, so the changes become atomic. Maybe in a single threaded world this is not that much of a problem, but imagine a multithreaded application where code might see a partially updated instance (by another function) of an object. Data would be inconsistent.

If you are interested in immutability, there is an awesome javascript library to check out called <a href="https://immutable-js.github.io/immutable-js/" target="_blank" rel="noopener nofollow">Immutable</a>.

We have just scratched the surface of functional programming. There are a lot more concepts (function composition, currying etc), libraries and standard library constructs that can help you work in a functional programming fashion with javascript. In order to find out more, you can check libraries like <a href="https://ramdajs.com/" target="_blank" rel="nofollow noopener">Ramda</a> or <a href="https://github.com/lodash/lodash/wiki/FP-Guide" target="_blank" rel="noopener nofollow">Lodash FP</a>. Also, there is an awesome curated list of material on functional programming for javascript <a href="https://github.com/stoeffel/awesome-fp-js" target="_blank" rel="noopener nofollow">here</a> if you want to dig deeper into the subject.

That's all for now!
