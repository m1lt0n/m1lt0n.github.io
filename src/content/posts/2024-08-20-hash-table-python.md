---
title: 'Building a hash table in python'
published: 2024-08-20 11:00:00 +0300
tags: ['python', 'hashing']
---

Recently, while I was reading about the implementation of Hash in ruby (similar to a dict in python) and wrote a simple implementation of <a href="https://en.wikipedia.org/wiki/Hash_table" target="_blank" rel="noopener nofollow">a hash table</a> in python. There are many benefits to using hash tables. The main one is that you have a constant lookup time when retrieving a value (think O(1)). Implementing them is based on hashing and is pretty much similar to what you would do when sharding a database and looking up only part of the data to speed things up (or to distibute a large dataset over multiple "places").

I'll share the code first below and discuss it a bit:

```python showLineNumbers
class Hash:
    def __init__(self):
        self._buckets = 30
        self._bucket_capacity = 20
        self._data = [[] for i in range(0, self._buckets)]

    def set(self, key, val):
        # Find the bucket where the key/value pair will be stored
        bucket = hash(key) % self._buckets

	for pair in self._data[bucket]:
	    if pair[0] == key:
		pair[1] = val
		return

        # If the bucket is already full, rehash the table first and then store it
        if len(self._data[bucket]) == self._bucket_capacity:
            self._buckets *= 2
            self._rehash()
        self._data[bucket].append([key, val])

    def get(self, key):
        # Find the bucket where the key/value pair lives and search for it in the bucket
        bucket = hash(key) % self._buckets

        for k, v in self._data[bucket]:
            if k == key:
                return v
        return None

    def _rehash(self):
        # Recalculate the bucket index of each key/value pair and put them in their new position
        new_data = [[] for i in range(0, self._buckets)]
        for bucket in self._data:
            for k, v in bucket:
                bucket = hash(k) % self._buckets
                new_data[bucket].append([k, v])
        self._data = new_data
```

The interface of `Hash` has 2 main methods: `set` and `get`. `set` is used to set a key/value pair and `get` to retrieve a value by providing a key. The important bit related to our topic is the "private" `_rehash` method. The `Hash` class internally stores data in a list of lists (buckets). The index of the list to add a key/value pair is determined by hashing the key and getting the modulo with the number of lists (buckets).

Example:

```python showLineNumbers
h = Hash()
h.set('c', 'some value')

# Under the hood, we calculate:  hash('c') % 30 => 27
# And we append ('c', 'some value') to the 28th bucket from the 30 that the Hash class creates by default
```

Hashing gives us the benefit of constant lookup time, because we quickly identify the "bucket" our data live in and then we only need to iterate over the items of just one bucket (one list instead of all 30 lists). There is one caveat, though: we don't want to have the list of each bucket grow forever, as the lookup time will start increasing as we add more items in the hash table.

Here's were the `_rehash` method comes into play. We determine a "capacity" for each bucket and when the list reaches this, we increase the number of buckets (in the implementation, we double them, so that we keep the items of each bucket low). This means though that we need to recalculate the bucket of each key/value pair, because the modulo will be done with 60 instead of 30, and reallocate pretty much every key/value pair to a different bucket.

This is an expensive operation, but adjusting the capacity, number of buckets and the multiplier when rehashing, we can keep it to a minimum, so that it doesn't kick in many times when adding data to the hash table.

In a future post, we'll discuss about consistent hashing, which further improves how many key/value pairs have to move (instead of every single one) when rehashing. Probably it would be an overkill for hash tables / dicts, but in the case of sharding as I mentioned in the beginning of the post, where data actually move between hosts, reducing the number of items that need to move becomes quite crucial.

That's pretty much for now!
