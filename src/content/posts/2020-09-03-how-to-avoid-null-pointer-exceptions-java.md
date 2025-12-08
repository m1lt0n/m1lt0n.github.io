---
title: 'Quick tip: Avoiding null pointer exceptions in Java'
published: 2020-09-03 17:00:00 +0300
tags: ['java', 'exceptions', 'tips']
---

Admit it. It has happened (not even just once) to all of us. Building something with Java and getting null pointer exceptions because: a) we did not check for null value of objects and/or b) we did not have tests covering null arguments passed to our functions.

When a variable (or function parameter) has an object type (some class, an array, a string etc), null is a legitimate value. Null pointer exceptions occur when we try to access methods of an object while it has the null value.

How can we avoid this? Here are some quick tips for handling null pointer exceptions (if you have Java 9 installed, you can try out some of these examples in jshell, and avoid creating a mini "application"):

```java
class Example {
  public static void main(String[] args) {
    String name = null;

    System.out.println(name.length());
  }
}
```

In the example above, we assign null to a string and then try to access the string's length. This throws a NullPointerException. This is an easy fix, we just need to check if the name is null:

```java
class Example {
  public static void main(String[] args) {
    String name = null;

    if (name == null) {
      // handle null value with your logic here
    } else {
      System.out.println(name.length());
    }
  }
}
```

Another case (I have faced this quite a few times in the past) is when string conditionals / comparisons are involved. E.g.:

```java
class Example {
  public static void main(String[] args) {
    String name = null;

    if (name.equals("John")) {
      System.out.println("Hello John!")
    } else {
      System.out.println("Hello Stranger!")
    }
  }
}
```

Since name is null in the example above, calling the equals method of strings fails with a NullPointerException. There are 2 options here:

- check for null value and then perform the comparison (i.e. `name != null && name.equals("John")`)
- reverse the strings (since "John" is a non-null string for sure (i.e. `"John".equals(name)`)

The choice is yours :) The same tips we mentioned above for local variables apply for method arguments, too.

Finally, here is another option (for Java 8 and above), that takes advantage of the Optional value container object (find out more <a href="https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html" target="_blank" rel="nofollow noopener">here</a>). Optional is an object that contains a value and can contain a null value, too. It is quite useful because it has an API that allows us to chain method calls even in the case of null values. Let's see an example:

```java
import java.util.Optional;

class Example {
  public static void main(String... args) {
    String name = "test";
    Optional<String> safeName = Optional.ofNullable(name);

    if (safeName.isPresent()) {
      System.out.println(safeName.map(String::length).get());
    }
  }
}
```

There are several things to notice in the example above. First, we create a `safeName` variable that build an Optional container around the name variable. This gives us a nice API to check if the optional has a value (using the `isPresent` method). Second, the Optional object has a nice method `map` that can be called without an issue regardless of the underlying value. This means that if name is null, the call to map would return an Empty Optional, otherwise an optional with an underlying value.

It might look like we didn't achieve much and you might be right for this example, but think about how much more bulletproof your code can be if your classes' methods have optionals instead of objects in their signature. Optional conveys meaning in the sense that someone expects to find null values (since the parameter is marked as an Optional) and is more probable to check for them.

That's all for now!
