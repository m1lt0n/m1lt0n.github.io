---
title: 'Chat with a PDF file using Ollama and Langchain'
published: 2024-07-24 14:00:00 +0300
tags: ['python', 'llm', 'pdf']
---

As lots of engineers nowadays, about a year ago I decided to start diving deeper into <a href="https://en.wikipedia.org/wiki/Large_language_model" target="_blank" rel="noopener nofollow">LLMs</a> and <a href="https://en.wikipedia.org/wiki/Artificial_intelligence" target="_blank" rel="noopener nofollow">AI</a>.

In this post, I won't be going into detail on how LLMs work or what AI is, but I'll just scratch the surface of an interesting topic: RAG (which stands for Retrieval-Augmented Generation). It's an approach where you combine LLMs with traditional search engines to create more powerful AI systems.

As a way to learn about the tooling and concepts related to the topic, I like to build small projects/PoCs that can help me understand these technologies better. One of those projects was creating a simple script for chatting with a PDF file. The script is a very simple version of an AI assistant that reads from a PDF file and answers questions based on its content. Note: this is in no way a production-ready solution, but just a simple script you can use either for learning purposes, or for getting some decent answer back from your PDF files.

The tools I used for building the PoC are:

1. <a href="https://www.langchain.com/" target="_blank" rel="noopener nofollow">LangChain</a> - a framework that allows you to build LLM applications. The framework provides an interface for interacting with various LLMs, is quite popular and well-documented and has lots of examples on how to use it.
2. <a href="https://ollama.com/" target="_blank" rel="noopener nofollow">Ollama</a>, a tool that allows you to run LLMs locally. There's a list of LLMs available in the Ollama website.

At a very high level, LLMs are pretrained models on huge amounts of data and can be fine-tuned to specialise for specific tasks (eg programming). While some models (eg gpt4) are very powerful and can be valuable out of the box, there are some cases where they may lack context for answering questions, eg because the PDF document (in our case) we want to ask questions about was not part of the training data of the model.

This is where <a href="https://blogs.nvidia.com/blog/what-is-retrieval-augmented-generation/" target="_blank" rel="noopener nofollow">Retrieval Augmented Generation (RAG)</a> comes in handy. RAG is a technique that combines the strengths of both Retrieval and Generative models to improve performance on specific tasks. In our case, it would allow us to use an LLM model together with the content of a PDF file for providing additional context before generating responses.

For starters and in order to make the script run locally, some python dependencies need to be installed. So, let's set up a virtual environment and install them:

```bash
python -m venv venv
source venv/bin/activate
pip install langchain langchain-community pypdf docarray
```

Next, download and install Ollama and pull the models we'll be using for the example:

- llama3
- znbang/bge:small-en-v1.5-f32

You can pull the models by running `ollama pull <model name>`

Once everything is in place, we are ready for the code:

```python
from langchain_community.llms import Ollama
from langchain_community.document_loaders import PyPDFLoader
from langchain.prompts import PromptTemplate
from langchain_community.vectorstores import DocArrayInMemorySearch
from langchain_community.embeddings import OllamaEmbeddings
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from sys import argv

# 1. Create the model
llm = Ollama(model='llama3')
embeddings = OllamaEmbeddings(model='znbang/bge:small-en-v1.5-f32')

# 2. Load the PDF file and create a retriever to be used for providing context
loader = PyPDFLoader(argv[1])
pages = loader.load_and_split()
store = DocArrayInMemorySearch.from_documents(pages, embedding=embeddings)
retriever = store.as_retriever()

# 3. Create the prompt template
template = """
Answer the question based only on the context provided.

Context: {context}

Question: {question}
"""

prompt = PromptTemplate.from_template(template)

def format_docs(docs):
  return "\n\n".join(doc.page_content for doc in docs)

# 4. Build the chain of operations
chain = (
  {
    'context': retriever | format_docs,
    'question': RunnablePassthrough(),
  }
  | prompt
  | llm
  | StrOutputParser()
)

# 5. Start asking questions and getting answers in a loop
while True:
  question = input('What do you want to learn from the document?\n')
  print()
  print(chain.invoke({'question': question}))
  print()
```

Let's see how the script works step by step:

1. We first create the model (using Ollama - another option would be eg to use OpenAI if you want to use models like gpt4 etc and not the local models we downloaded).
2. We then load a PDF file using PyPDFLoader, split it into pages, and store each page as a Document in memory. We also create an Embedding for these documents using OllamaEmbeddings. What are embeddings? They are vectors/matrices of numbers that represent the semantic meaning of words or phrases within a document. You may notice that we have used different models for embeddings and LLM (Language Model), that's because some models are built (and are really good at) being used as embeddings models, others as language model etc. You can experiment with different models (for example, using llama for embeddings, too, led to quite worse results in my case).
3. We create a simple prompt template for asking the question and providing the context (ie the relevant document chunks that the retriever will pull based on the question). There's definitely room for improvement of the prompt, but since this is just an example script, it works fine.
4. Build the chain: piping operations works in a similar way as piping operations linux (left to right): first we take input (question), then pass through retriever which retrieves relevant documents based on question, format these documetn chunks into readable form and feed them to LLM for generating answer. We use an `StrOutputParser` to get the response as a string rather than as an object.
5. We create a loop getting the user's input and printing out the LLM's response.

Note that in order to have a relatively flexible script, the PDF file's path is passed as an argument, so we can run the script like that:

```bash
python main.py <PDF_FILE_PATH>
```

That's pretty much it! Now, we can go ahead and ask questions about our documents.

We just scratched the surface here ofcourse and there are lots of things we can do with Langchain. Specifically, we can use a persistent vector store (vs the in-memory one we used), so that we don't have to recalculate embeddings every time we restart the script. We can also improve the prompt as I mentioned to get even better answers. Langchain provides great abstractions that make it easy for you to add the history of questions and answers as context for future queries, so you easily ask follow-up questions based on previous interactions, but I'll leave this task to you :)

That's all for now!
