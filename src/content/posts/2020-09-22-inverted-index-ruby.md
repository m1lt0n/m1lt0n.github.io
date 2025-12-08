---
title: 'Searching with an inverted index in Ruby'
published: 2020-09-22 08:00:00 +0300
tags: ['ruby', 'search', 'index']
---

Recently, I read blog post about elasticsearch, called <a href="https://www.elastic.co/blog/found-elasticsearch-from-the-bottom-up" target="_blank" rel="noopener nofollow">Elasticsearch from the Bottom Up</a>. A data structure that is very important to performing full-text searches in this context is the <a href="https://en.wikipedia.org/wiki/Inverted_index" target="_blank" rel="noopener nofollow">inverted index</a>. In this post, I will use Ruby a simple inverted index as well as some ways to query it.

So, first things first, let's assume we have a number of documents and we want to search for a term (e.g. a word) in them. An inverted index is a very useful data structure in this context. An inverted index maps terms (e.g. words) to references to the documents (e.g. "word 1" -> [document 1, document 2]). Once the inverted index is built, it is quite easy to perform a search and get back the list of documents that include that term. This would be the simplest form of a full-text search engine.

Of course, full-featured full-text search engines like elasticsearch or solr have tons of features regarding the way to query for a term or combination of terms, as well as functionality to retrieve related documents (i.e. recommendations / more like this etc) and a lot more.

Ok, how would we build a simple inverted index ourselves? Let's see an initial implementation and explain it:

```ruby
class InvertedIndex
  def initialize
    @words = {}
  end

  def add_doc(doc_id, doc_str)
    doc_str.gsub(/[^[[:word:]]+]/, ' ').split.each do |word|
      add_word(word.downcase, doc_id)
    end
  end

  def exact_term(word)
    words[word] || []
  end

  def term_starts_with(prefix)
    result = []
    prefix = prefix.downcase

    words.keys.each do |key|
      result += words[key] if key.start_with?(prefix)
    end

    result || []
  end

  private

  attr_reader :words

  def add_word(word, doc_id)
    words[word] = [] if words[word].nil?
    words[word] << doc_id unless words[word].include?(doc_id)
  end
end
```

In the example above, we create an InvertedIndex class that holds the inverted index in the `words` attribute as a hash. Entries of `words` will be in the form of `"word1" => [doc_id1, doc_id2]`. Let's explain the API of the inverted index class.

First of all, there is the add_doc method, that allows indexing a document. We split the content of the document (we may have read this document from a file into a string) into words (removing punctuation etc) and we create or update the specific word's mapping. When adding a document, we use a notion of document id, which could be a location to a filesystem, a document id in a database etc.

Actually, we are done with creating the index (I will explain the limitations of such an index later)! Now, we need some way to query the index. In the example above, I have added 2 different methods. Search by exact term (i.e. providing a word) or by providing part of a term.

The `exact_term` query just gets the entry from the hash if it exists or returns an empty array. This is so easy due to the underlying data structure we have used (the hash table `words`). A hash is great for looking up based on key, it is constant time for any size of entries, so everything is cool :)

The `term_starts_with` method on the other hand, looks for part of a word (e.g. sun would return documents that include the word sun, but also the word sunny). In this case, I have gone with a super simple implementation of traversing all the terms in the `words` hash table, which means that for large indexes this would be slow (since the time complexity of this operation is O(n)). In a real-world implementation of the index we might go with a <a href="https://en.wikipedia.org/wiki/Trie" rel="nofollow noopener" target="_blank">prefix tree</a> (also called trie) that would lead to faster search (O(logn) complexity).

Let's see how we would query this index:

```ruby
idx = InvertedIndex.new

idx.add_doc('1', 'Today is a sunny day. I am happy!')
idx.add_doc('2', 'Yesterday there was sun, too.')
idx.add_doc('3', 'Sunny is better than rainy.')

p idx.exact_term('sun') # => ["2"]
p idx.term_starts_with('sun') # => ["1", "2", "3"]
```

Querying for the exact term "sun" returns only document 2 that includes the exact word, while querying for term starting with sun, returns all documents, as the word sunny matches the search criteria, too.

This was a simple implementation of an inverted index. As you can see, the kinds of queries we need to perform dictate the way our data will be stored and we might need several indexes in order to be able to perform different kinds of queries.

That's all for now!
