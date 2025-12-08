---
title: 'New behavior when exiting activerecord transactions with return in Rails 7'
published: 2023-02-11 14:00:00 +0300
tags: ['ruby', 'rails', 'activerecord']
---

Recently, I decided to upgrade one of my projects from Rails 6.0 to 7.0. After going through the changelogs of each release between 6.0 and 7.0 and through the excellent <a href="https://guides.rubyonrails.org/upgrading_ruby_on_rails.html" target="_blank" rel="nofollow noopener">official upgrade guide</a>, I started making the required changes.

After making all the necessary changes, I ran the test suite of the project (thankfully, the project has a high code coverage and there are unit and functional tests for lots of its parts) and got a handful of test failures. What kind of failures?

There were a set of tests that were testing a background job (for which the project uses delayed job) and quickly I found out that all of the test failures were relevant with some database records not being created. After debugging (using byebug) to verify that the code goes through the expected branch in one of those test cases (it did), it looked like when returning from within a transaction, the transaction was being rolled back.

Here's an example of what the code looked like:

```ruby showLineNumbers
class SampleJob < ApplicationJob
  def perform(user_id)
    ActiveRecord::Base.transaction do
      user = User.find_by(id: user_id)
      if user.nil?
        AuditLog.create(message: "SampleJob terminating for user with id #{user_id}. User no longer exists")
        return
      end

      # Main logic of the job (persisting to the database based on some more logic etc)
    end
  end
end
```

Thankfully, I had written tests for this flow and one of the tests that failed was checking that if the user is not found, an audit log record should be persisted. While the test was passing with Rails 6.0, it wasn't with Rails 7.0. Looking for any behavior changes trying to exit from within a transaction, I found out that starting with Rails 6.1, there was a <a href="https://github.com/rails/rails/pull/29333" target="_blank" rel="nofollow noopener">pull request</a> that was merged and had to do with deprecating commiting the transaction when using return or throw within the transaction block. Aha!

So, using return now caused not only stopping execution of the code of the job, but also rolling back the transaction (and thus not creating the AuditLog record). So, what's the solution if you still want to commit the transaction but stop execution, too? Using `next` instead of `return`. This simple change fixed the newly introduced bug and the tests were green again! Hurrah!

Alternatively (not applicable in all cases, though, because it depends on the logic of your code), it could also make sense for the logic to not be part of the transaction (whenever possible) and have the transaction in just a part of the code. In the example above, this can be done by moving the retrieval of the user code and the creation of the AuditLog record outside the transaction, but this is not possible in all cases, where `next` comes into play.

That's all for now!
