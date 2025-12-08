---
title: 'Deleting and re-inserting a record in SQLAlchemy in the same transaction'
published: 2021-12-02 08:00:00 +0300
tags: ['sqlalchemy', 'orm', 'python']
---

Recently, I was puzzled with an issue while working on one of my projects. In an endpoint I was building, I had to delete an existing record of a table and create a new one in a way that both the deleted record and the new one would have the same values for columns marked unique (so, the same constraints).

A simplified version of the way I tried to do this is depicted below (the code below assumes you have sqlalchemy installed and sqlite installed on your system):

```python
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import Session, declarative_base

engine = create_engine('sqlite:///:memory:')

Base = declarative_base(bind=engine)

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True)


Base.metadata.create_all()


# at some point, a user is created
with Session(engine) as session:
    session.add(User(email='john.doe@example.com'))
    session.commit()


# later, we want to delete the user and create
# a new user with the same email in the same transaction
with Session(engine) as session:
    user = session.query(User).filter(User.email == 'john.doe@example.com').one()
    session.delete(user)
    session.add(User(email='john.doe@example.com'))
    session.commit()
```

Pretty simple, right? You expect this code (the last block specifically) to delete the user and create a new user. But what actually happens is that on `session.commit()`, an exception is raised. Specifically:

```
sqlalchemy.exc.IntegrityError: (sqlite3.IntegrityError) UNIQUE constraint failed: users.email
```

After some time of frustration, I had an assumption that this error could only happen if the order of the queries performed is different than the intented order of the code, meaning that SQLAlchemy is apparently first trying to insert the new record (and thus the integrity error) and then delete instead of the other way around.

In order to test this assumption, I updated the code above and added a `session.flush()` after the delete statement. Problem solved! By flushing, we write out the pending delete statement first, so when we commit the session, only the insert statement is flushed before commiting the transaction. The original issue is caused by the session’s "unit of work dependency solver".
Searching for the issue, I found a github issue in the sqlalchemy repository. It's a long thread since 2012: <a href="https://github.com/sqlalchemy/sqlalchemy/issues/2501" target="_blank" rel="noopener nofollow">the DELETE before INSERT problem</a>. The issue is still open, but somewhere along the comments (the most recent ones from 2020), there is a suggestion to add an example in the documentation to actually solve the issue by adding a `session.flush` in the relevant places :)

That was a nice issue to solve and in the way, I learned a bit more about SQLAlchemy.

That's all for now!
