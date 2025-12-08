---
title: 'Awesome cli tools: HTTPie http client'
published: 2021-02-17 09:00:00 +0300
tags: ['cli', 'httpie']
---

We frequently find ourselves making http calls from the terminal: for testing out an external API we're integrating into our projects, or for testing APIs we build locally and in many other cases, too.

In the past, when I wanted to test out an API I was building locally, I would either have to use a rest client with a graphical interface (e.g. <a href="https://insomnia.rest/" target="_blank" rel="nofollow noopener">Insomnia</a> or one of the several chrome or firefox addons/extensions) or cURL.

While cURL (check out the official <a href="https://curl.se/docs/manual.html" target="_blank" rel="nofollow noopener">tutorial</a>) is powerful and you can do lots of things with it, it is quite verbose in several cases. This is where HTTPie comes in. HTTPie is a user-friendly command-line HTTP client.

Regarding installation, if you are working on linux, httpie is probably available via your package manager. For Windows and macOS, you can find more information in the <a href="https://httpie.io/docs#installation" target="_blank" rel="nofollow noopener">official documentation</a>.

There are several great things about HTTPie. First of all, its pretty output out of the box. While with cURL, I had to pass its results through a tool like jq (check out <a href="/tools/jq/json/2020/08/30/jq-json-processor.html">my blog post on jq</a>) to pretty print json results, for example. HTTPie colorizes and formats the terminal output by default. Yay!

Below is an example from calling an endpoint of the Star wars API (you can check the website at <a href="https://swapi.dev/" target="_blank" rel="noopener nofollow">https://swapi.dev/</a>) by running `http https://swapi.dev/api/people/1/`:

```bash
HTTP/1.1 200 OK
Allow: GET, HEAD, OPTIONS
Connection: keep-alive
Content-Type: application/json
published: Wed, 17 Feb 2021 07:24:36 GMT
ETag: "bf44153838a0871ffc5cc3aaee8029d0"
Server: nginx/1.16.1
Strict-Transport-Security: max-age=15768000
Transfer-Encoding: chunked
Vary: Accept, Cookie
X-Frame-Options: SAMEORIGIN

{
    "birth_year": "19BBY",
    "created": "2014-12-09T13:50:51.644000Z",
    "edited": "2014-12-20T21:17:56.891000Z",
    "eye_color": "blue",
    "films": [
        "http://swapi.dev/api/films/1/",
        "http://swapi.dev/api/films/2/",
        "http://swapi.dev/api/films/3/",
        "http://swapi.dev/api/films/6/"
    ],
    "gender": "male",
    "hair_color": "blond",
    "height": "172",
    "homeworld": "http://swapi.dev/api/planets/1/",
    "mass": "77",
    "name": "Luke Skywalker",
    "skin_color": "fair",
    "species": [],
    "starships": [
        "http://swapi.dev/api/starships/12/",
        "http://swapi.dev/api/starships/22/"
    ],
    "url": "http://swapi.dev/api/people/1/",
    "vehicles": [
        "http://swapi.dev/api/vehicles/14/",
        "http://swapi.dev/api/vehicles/30/"
    ]
}
```

There is no straightforward way to get the same output using cURL. You can get something similar by running `curl https://swapi.dev/api/people/1/ | python -m json.tool`, but this just formats the output, not colorizing it. Another way is to install jq and run `curl https://swapi.dev/api/people/1/ | jq .`.

In both cases, though, we're missing the information about the response (headers etc). With cURL, if we want to get information about the response, we could do `curl -i https://swapi.dev/api/people/1/`, but in this case we cannot pipe the output to a json formatter.

Apart from the syntax highlighting and pretty formatting of HTTPie, another advantage of it is its expressive syntax. Let's say you want to send a POST request and pass some data to it. Let's assume that you have an endpoint of an API you're building, that creates a user: http://localhost:5000/users.

Using cURL, you could hit this endpoints by doing this:

```bash
curl -X POST -H 'Content-Type: application/json' -d '{"name": "Pantelis"}' http://localhost:5000/users
```

To do the same thing in HTTPie:

```bash
http post http://localhost:5000/users name=Pantelis
```

How awesome is that? HTTPie's sensible defaults make it really easy to work with it while you're building APIs.

We have just scratched the surface here, but there are lots of great features that HTTPie offers: URL shortcuts for localhost (to save a bit of typing :) ), automatic addition of headers for json (content type and accept), getting request data from a file and many more.

Check out the <a href="https://httpie.io/docs" target="_blank" rel="noopener nofollow">documentation</a> to find out more!

That's all for now!
