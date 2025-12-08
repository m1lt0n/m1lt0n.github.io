---
title: 'Encryption the easy way with lockbox gem'
published: 2020-10-24 13:00:00 +0300
tags: ['encryption', 'ruby']
---

There are several occasions where we need to encrypt some data, whether they are fields in a database or files. In some cases, encryption is needed in order to secure secrets that are stored in a database (e.g. access tokens of an external API used by your project). In other cases it might be for compliance with privacy laws (e.g. GDPR).

An example use case for encryption might be for not saving the emails of your users in plain text in a database. If the database (e.g. a database backup) becomes compromised, getting access to these personal information will be much much harder. If you are working with Ruby, there is an awesome gem that offers an easy way to encrypt data: `lockbox`.

The author <a href="https://github.com/ankane" target="_blank" rel="noopener nofollow">Andrew Kane</a> has created a remarkable amount of great gems for encryption, machine learning etc that are worth checking out.

Let's go ahead and see lockbox in action.

In order to install lockbox, add this line in the Gemfile of your project:

`gem 'lockbox'`

Lockbox needs a "master" encryption key and the gem provides a key generation method. To get a key:

```ruby
Lockbox.generate_key
```

You can use this key to create a lockbox and start encrypting and decrypting data or files, so it is good to save the generated key somewhere (e.g. in Rails credentials if you are working with a RoR project, in an environment variable in other cases, whatever you use for configuration).

Lockbox is integrated with Rails to help us use it right away. For example, you can use it with ActiveRecord in order to encrypt database fields. To do so you need:

- To set the encryption key, e.g. in an initializer (assuming you have the key stored in Rails credentials):

```ruby
Lockbox.master_key = Rails.application.credentials.lockbox_master_key
```

- Create a migration to add the field that will hold the encrypted values. By default, the field names are {some_name}\_ciphertext. So, if you want to encrypt an email, you would name the field email_ciphertext.

- Update your model (let's assume you have a `User` model and you have just added an email_ciphertext field:

```ruby
class User < ApplicationRecord
  encrypts :email

  # rest of the model's code
end
```

That's all! Now, every time you create, save or update a record, the email passed to the relevant methods will be encrypted first and stored in the email_ciphertext field. Also, each time you retrieve the email field from an instance of a User, it will be automatically decrypted and the plain text email will be returned back.

An important note is that since the data in your email field are stored encrypted, you miss some of the functionality compared to the plain text version. Specifically, you can no more search by email. In order to get back this kind of functionality, the same author has created the blind index gem, that lets you search by an encrypted field (its full value, though, `like` queries are not available even with the blind index).

A super cool feature of lockbox is the fact that you can gradually migrate a field from a plain text version to an encrypted one without downtime, which is quite useful if you already have data in plain text and want to switch them to encrypted versions in an existing project. I will not go into more detail about that in this post though.

Let's see how lockbox can be used outside of Rails or ActiveRecord, e.g. to encrypt strings:

```ruby
key = Lockbox.generate_key # you should have this stored in some kind of config
lockbox = Lockbox.new(key: key)
encrypted_value = lockbox.encrypt('the value to encrypt')
decrypted_value = lockbox.decrypt(encrypted_value)
```

It is really easy to also encrypt files (either local, or file uploads from carrierwave etc). Check out <a href="https://github.com/ankane/lockbox" target="_blank" rel="noopener nofollow">the documentation of the gem</a> for more examples.

Instead of rolling your own encryption functionality, I strongly advise using a well thought solution like lockbox for several reasons. For example, apart from having a master key for the encryption, each field is encrypted with a different key (part of it is stored in the encrypted field, kind of like a salt in hashed passwords) to make it hard to break with brute force attacks. Also, the migration and key rotation functionality out of the box and a lot more that is time consuming to build yourself. Encryption is hard and it is always good to rely on good solution instead of just building new tools just for the sake of it.

That's all for now!
