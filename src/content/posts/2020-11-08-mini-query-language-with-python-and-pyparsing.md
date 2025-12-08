---
title: 'Parsing a mini query language with python and pyparsing'
published: 2020-11-08 13:00:00 +0300
tags: ['python', 'parsing', 'pyparsing']
---

Recently, I had to parse an SQL-like statement coming in as a query parameter for an python API endpoint. This mini query language had to support AND, OR and NOT operations and allow nested expressions (with parentheses). Some examples would be statements like the following:

- email = john@example.com
- email = jane@example.com AND age = 30
- email = john@example.com AND (age < 30 OR age > 60)

What are the options for performing such a task? Generally speaking, one way to go would be be a do-it-yourself solution that would include a tokenizer to break down the statements into tokens and then a parser to build an abstract syntax tree (AST) that would later be interpreted in a proper way (e.g. to "translate" the AST into SQL or an elasticsearch query, whatever the API is using in the backend).

Nevertheless, I always try to find out tools and libraries that have already solved the problem, which would let me focus on the actual problem at hand (translating the statement to an SQL statement). There are several language parsing libraries in python. A really great one, which is well documented, easy to use and packed with features is pyparsing. You can check out pyparsing on <a href="https://pypi.org/project/pyparsing/" target="_blank" rel="noopener nofollow">Python Package Index (pypi)</a>.

So, let's start building our expression parser! I'm using python3 in this tutorial, so let's first create a virtual environment using venv:

```bash
python3 -m venv ./env
```

Next, let's activate the newly created virtual environment:

```bash
. env/bin/activate
```

Now, let's install pyparsing:

```bash
pip install pyparsing
```

The pyparsing library has a great documentation. As we will only use a small fraction of the features provided by pyparsing, you can check out more <a href="https://pyparsing-docs.readthedocs.io/en/latest/index.html" target="_blank" rel="noopener nofollow">in the official documentation</a>.

Pyparsing allows the creation of expressions and composition of expressions from other smaller and simpler ones. How would we approach our problem? The simplest expression in our case is a simple clause which is structured as: {field} {=/>/<} {value}. For example:

- name = John
- age > 30
- age < 20

Let's see how we could parse this kind of expressions:

```python
import pyparsing as pp

clause = pp.Word(pp.alphanums) + pp.oneOf('= < >') + pp.Word(pp.alphanums)
```

Using some of the expression classes provided by pyparsing, we have created a simple expression that is composed of alphanumerical characters, an operator and more alphanumerical characters. Let's use the expression to parse a statement:

```python
result = clause.parseString('age > 20')
```

The result of `parseString` is an instance of ParseResults. Its string representation is:

```python
(['age', '>', '20'], {})
```

The first item is the parsed expression (all the tokens) and the second is a dict. In order to access the individual tokens, you can get them by index, like this:

```python
>>> result[0]
'age'
```

There is a better way to structure the result of the parsing. Pyparsing allows setting names to expressions, so we could give names to our parts of the clause and see what the result of parsing will be:

```python
clause = pp.Word(pp.alphanums)('field') + pp.oneOf('= < >')('operator') + pp.Word(pp.alphanums)('value')
result = clause.parseString('age > 20') # (['age', '>', '20'], {'field': ['age'], 'operator': ['>'], 'value': ['20']})
```

Much better! Now, we can access the parse results by key:

```python
>>> result['field']
'age'
```

One thing that is worth mentioning is that pyparsing allows setting parse actions on expressions, which would allow us to hook into the parsed results and use or transform the tokens any way we want. For example:

```python
import pyparsing as pp

clause = pp.Word(pp.alphanums)('field') + pp.oneOf('= > <')('operator') + pp.Word(pp.alphanums)('value')

class ClauseExpression:
    def __init__(self, tokens):
        self.tokens = tokens

    def __repr__(self):
        return "field: {}, operator: {}, value: {}".format(*self.tokens)

    def asDict(self):
        return self.tokens.asDict()

clause.setParseAction(ClauseExpression)
result = clause.parseString('age > 20')

print(result) # returns [field: age, operator: >, value: 20]
print(result[0].asDict()) # returns {'field': 'age', 'op': '>', 'value': '20'}
```

Cool! So, now that we can parse simple statements, how do we implement the AND/OR/NOT operators? It couldn't be easier, as pyparsing provides that functionality out of the box with `infixNotation`:

```python
statement = pp.infixNotation(clause, [
    ('NOT', 1, pp.opAssoc.RIGHT),
    ('AND', 2, pp.opAssoc.LEFT),
    ('OR', 2, pp.opAssoc.LEFT)
])

result = statement.parseString('name = John AND (age > 20 OR age <50)')

print(result[0]) # returns [{'field': 'name', 'op': '=', 'value': 'John'}, 'AND', [{'field': 'age', 'op': '>', 'value': '20'}, 'OR', {'field': 'age', 'op': '<', 'value': '50'}]]
```

Awesome! With so little effort, we are able to have nested expressions, order of precedence of operators (NOT -> AND -> OR) dicated by the index of the list of operators provided in `infixNotation`. The result as we printed it out is well structured: a clause, an operator and then the nested sub-statement as a separate array, indicating the parentheses. From here, we can transform the results any way we want.

For the particular task I had to perform, I transformed the array of the parse result into a kind of abstract syntax tree like this:

```python
{
  op: 'AND',
  items: [
    {
      op: '=',
      field: 'name',
      value: 'John'
    },
    {
      op: 'OR',
      items: [
        {
          op: '>',
          field: 'age',
          value: '20'
        },
        {
          op: '<',
          field: 'age',
          value: '50'
        }
      ]
    }
  ]
}
```

Achieving a structure like this is quite easy using a recursive function that handles arrays or objects differently (statement vs clauses), so I won't show it here. After generating the syntax tree, any kind of query can be built (an actual SQL query, a query to elasticsearch, to a no-sql database like mongo etc), which is a great thing, as it makes our code extensible.

There are a lot more to pyparsing than the things I described here. There are lots of expressions (oneOf, NotAny, ZeroOrMore, OneOrMore, Optional etc) that can be used to build complex expressions. There is a learning curve, but the alternative (building your own parser), while it may be tempting, is not that efficient in my view.

That's all for now!
