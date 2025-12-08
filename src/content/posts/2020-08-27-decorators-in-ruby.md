---
title: 'How to work with decorators in ruby'
published: 2020-08-27 09:00:00 +0300
tags: ['ruby', 'decorators']
---

Sometimes, we find ourselves wanting to add functionality to objects of a class without affecting all objects of the class (unlike inheritance or composition via mixin modules).

Assume we have a `User` class like the one below:

```ruby
class User
  attr_reader :first_name, :last_name, :age

  def initialize(first_name, last_name, age)
    @first_name = first
    @last_name = last
    @age = age
  end
end
```

We now want to generate the full name of some users (based on some condition that is not important in the context of this post). What are our options?

One option would be to create a full_name method directly for the `User` class:

```ruby
class User
  # ...

  def full_name
    "#{first_name} #{last_name}"
   end
end
```

The disadvantage to this approach is that we add the functionality to all `User` instances, even the ones we don't want to have it or use it. Using inheritance (e.g. having a superclass implementing full_name and then `User` extend this class) has the same disadvantage along with all the risk of creating a whole hierarchy of classes just to add functionality that will be used only by some of them.

Another option is composition through mixins, like below:

```ruby
module FullName
  def full_name
    "#{first_name} #{last_name}"
  end
end

class User
  include FullName
  # ...
end
```

This approach would work and we can even add it to other classes or remove it from the `User` class in the future, if need be. Nevertheless, the functionality is added once again to all objects of the `User` class.

Here is where the decorator pattern comes in handy. Simply put, decorator is a class that extends the functionality of an object dynamically. Let's see a simple implementation of a decorator:

```ruby
class UserDecorator
  def initialize(user)
    @user = user
  end

  def full_name
    "#{user.first_name} #{user.last_name}"
  end

  def method_missing(meth, *args)
    if user.respond_to?(meth)
      user.send(meth, *args)
    else
      super
    end
  end

  def respond_to?(meth)
    user.respond_to?(meth)
  end

  private

  attr_reader :user
end
```

Now, for the **specific** users we want to have this extra functionality, we can user the decorator in place of a `User` instance: `decorated_user = UserDecorator.new(user)`. By using some metaprogramming (method_missing), we forward all method calls to `User` and extend the functionality in the definition of `UserDecorator`.

There are numerous advantages to this approach:

- the `User` class is not changed at all, no new responsibilities are added to this
- the `UserDecorator` class has clear responsibilities and we can easily see what is the functionality it adds to users
- the decorator can be wrapped by other decorators infinitely (not a great idea in my opinion, both in terms of performance and of readability of the code)

Finally, an approach from the ruby standard library (see more <a href="https://ruby-doc.org/stdlib-2.5.1/libdoc/delegate/rdoc/SimpleDelegator.html" target="_blank" rel="noopener nofollow">in the ruby docs</a>) is `SimpleDelegator`:

```ruby
class UserDecorator < SimpleDelegator
  def full_name
    "#{first_name} #{last_name}"
  end
end
```

`SimpleDelegator` is similar to the method_missing approach we built ourselves. The extra benefit of this approach - apart from not having to build it ourselves :) - is that there is a method `__setobj__`, where we can change the delegate object dynamically after instantiation (I cannot find any use to it currently, but in some contexts it might be needed).

Thanks all for now!
