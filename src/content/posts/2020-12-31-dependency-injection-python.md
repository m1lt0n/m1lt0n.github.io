---
title: 'Dependency injection in python'
published: 2020-12-31 10:00:00 +0300
tags: ['dependency injection', 'python']
---

Dependency injection is a technique that "injects"/passes dependencies between objects in a way that leads to code that is easier to test and maintain.

Some of the benefits of dependency injection are:

- avoids hardcoding dependencies between objects
- makes it easy to swap a dependency implementation with another one
- makes testing easier, as dependencies can be mocked or replaced with fakes

Let's see an example where dependency injection would be beneficial. Assume we have a service that creates a user for our web application. Once a user fills in a form with their username and password, we create the user and we send them a welcome email.

An initial implementation that does not take into advantage dependency injection would be the following:

```python
class UserSignupService:
    def __init__(self):
        self.email_service = EmailService()
        self.user_repository = UserRepository()

    def run(self, user_data):
        user = self.user_repository.create(user_data)
        self.email_service.send(
            to=user.email,
            subject='Welcome!',
            body='Welcome to our web app!'
```

In the code above, email service (which is responsible for sending emails to users) and user repository (which allows us to query and create users) are hardcoded in the `UserSignupService`.

There are several problems with this approach. First of all, unit testing this code would need us to patch at least the email service in order to avoid sending emails or needing a local email server just for that purpose. The same goes for user repository. We would need a database in place. There is nothing wrong with having a functional test that glues all of those things together, but unit testing would be quite hard with that approach.

Also, if we ever decide to replace EmailService with a new implementation, we would need to find all occurrences of EmailService within all the classes that use it. Apart from being error prone and a hard work to do so, it violates the single responsibility principle, as the `UserSignupService` for example, would have more than one reasons to be updated: apart from changing its own functionality, it would have to change every time the dependencies change.

What could we do differently? Let's see:

```python
class UserSignupService:
    def __init__(self, email_service, user_repository):
        self.email_service = email_service
        self.user_repository = user_repository

    def run(self, user_data):
        user = self.user_repository.create(user_data)
        self.email_service.send(
            to=user.email,
            subject='Welcome!',
            body='Welcome to our web app!'
        )
```

As simple as that! When we instantiate `UserSignupService`, we "inject" its dependencies. Now, we can replace the dependencies with mocks in our tests. Also, when we want to use another email service, we don't have to touch the code of `UserSignupService`. This type of dependency injection is called constructor dependency, because we explicitly pass the dependencies in the constructor of the class.

Another way to inject dependencies is with setter dependency. We can create a setter method, e.g. `set_email_service` that sets the value of the email_service. Another way to inject a dependency (which is very useful if the dependency is used in one method only) is to directly pass the dependency as an argument to that method.

There is still one problem, though. If `UserSignupService` is used in several places, if we change the email service implementation, we would still need to change its instantiation code in all those places. This issue can be solved by using a factory:

```python
def create_user_signup_service():
    return UserSignupService(EmailService(), UserRepository())
```

By using the factory, whenever there is a need for a change in any of the dependencies, we need to change it only in the factory. Is everything perfect? No. Instances of `UserSignupService` can still be created directly (without the use of the factory). If our application code uses the factory in some places and the constructor in other, changing a dependency will introduce a bug in our system. Is there a way to avoid it?

A very easy to use package for this reason is `inject`. Inject is a dependency injection container. Using inject, you can eliminate the need for the factory. Let's see an example using the <a href="https://github.com/ivankorobkov/python-inject" target="_blank" rel="noopener nofollow">inject package</a> (you can install it from pypi `pip install inject`):

```python
import inject

class EmailService:
    pass

class UserRepository:
    pass


def inject_config(binder):
    binder.bind(EmailService, EmailService())
    binder.bind(UserRepository, UserRepository())

inject.configure(inject_config)


class UserSignupService:
    @inject.params(email_service=EmailService, user_repository=UserRepository)
    def __init__(self, email_service, user_repository):
        self.email_service = email_service
        self.user_repository = user_repository

    def run(self, user_data):
        user = self.user_repository.create(user_data)
        self.email_service.send(
            to=user.email,
            subject='Welcome!',
            body='Welcome to our web app!'
        )

service = UserSignupService()
```

The functionality of `inject` is quite rich and we will not cover it here, but as you can see from the example, using inject we have the benefits of the factory we used above (change the bindings to email service in one place only) and also a single way to instantiate `UserSignupService`. If you are using python 3.5+ with type hints, injection becomes even easier (check out the package's documentation).

That's all for now!
