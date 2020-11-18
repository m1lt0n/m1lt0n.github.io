---
layout: post
title:  "Quick tip: Using UUIDs in python"
date:   2020-11-18 10:00:00 +0300
categories: python uuid
---
What is a UUID? It stands for **Universally Unique IDentifier** and it's just what its name implies. It can be used to identify resources, responses / requests (e.g. a unique request ID) and anything that needs an accompanying identifier.

While their name implies that UUIDs are unique, they are not. There is a very small, posibility for collisions, but it is so close to zero, that it is negligible.

UUIDs are standardized by the Open Software Foundation and there are several variations/versions of UUIDs, depending on they way they are generated. Python offers a uuid module that allows us to generate UUIDs of versions 1, 3, 4 and 5 (for more information about different UUID versions and how they are generated, check out <a href="https://en.wikipedia.org/wiki/Universally_unique_identifier" target="_blank" rel="noopener nofollow">wikipedia</a>.

I have been using UUIDs for several years now for several different use cases:

* As ids in database records (e.g. for user ids). Why? Because integer autoincrementing IDs that are exposed via APIs or in URLs reveal information you may not want to disclose to the public (e.g. the number of users your application has). 
* When needing random tokens. Random tokens may be used for one-time requests (e.g. forgot/reset password functionality), as nonces when they are requested from 3rd party APIs etc

So, let's see how the ```uuid``` python module is used.

{% highlight python %}
import uuid

u = uuid.uuid1() # returns a version 1 uuid, e.g. UUID('3f271878-2970-11eb-a9d6-779455a341a3')

# some useful attributes of a generated uuid:
u.version # returns the uuid version (in this case 1)
u.hex # returns the uuid as a 32 character hex string e.g. '3f271878297011eba9d6779455a341a3'
u.int # returns a 128 bit long integer e.g. 83944359609966917344188373021204103587
u.urn # returns the uuid as a uniform resource name e.g. urn:uuid:3f271878-2970-11eb-a9d6-779455a341a3
{% endhighlight %}

The examples above are for version 1 UUIDs, but the API is the same for other versions (e.g. version 4, which builds a random UUID).

Check out <a href="https://docs.python.org/3/library/uuid.html" target="_blank" rel="noopener nofollow">the uuid module</a>.

That's all for now!
