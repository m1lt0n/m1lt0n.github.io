---
title: 'Awesome cli tools: jq json processor'
published: 2020-08-30 09:00:00 +0300
tags: ['tools', 'jq', 'json']
---

There are some command line tools that I use almost on a daily basis and make my life a lot easier. One of those tools is <a href="https://stedolan.github.io/jq/" target="_blank" rel="noopener nofollow">jq</a>. Jq is a lightweight and flexible command-line JSON processor. Jq allows filtering and slicing of JSON data and is really easy to use.

In order to get and start using jq, download it from the <a href="https://stedolan.github.io/jq/" target="_blank" rel="noopener nofollow">official website</a>. If you are on linux, change the file's permissions to make it executable and you're ready to go. Also, if you are on linux, several distributions have jq in their repositories (e.g. in ubuntu you can get it with a simple `sudo apt get jq`)

Since jq needs works with JSON, we need a JSON file to work with. For the purposes of this post, we get a few commits from the github repo of the ruby programming language and store the resulting JSON into a `commits.json` file:

`curl https://api.github.com/repos/ruby/ruby/commits?per_page=10 > commits.json`

**Note:** If you don't have `curl` available in your system, you can just head over to a browser and save the contents of the page directly from there.

In order to see jq in action, we can pipe the content of commits.json to the jq command. The simplest jq command is `jq .`, which does no filtering and returns the whole input back, just formatted:

`cat commits.json | jq .`

Wow! That's some nice output. The contents of the file are pretty printed and have colors, too!

Let's see a more useful example though. If we examine the commits.json file, we see that the root element is an array and each commit is an object with several fields. Let's assume we're interested in the first commit only. Here's how we can get it:

`cat commits.json | jq .[0]`

If we want to get a subset of the commits from the file, the array/string slice is what we need:

`cat commits.json | jq.[0:5]`

The command above will return the first 5 items from the JSON file (index 5 is exclusive).

What about filtering content from each item in the array? Suppose we want to get the commit URL from all commits:

`cat commits.json | jq '.[] | .sha'`

The command above gets each object from the array and for each object gets its **sha** field (results will probably be different for you):

```
"726f2e59f9b0c7a69f540e09bab54ab17b013d56"
"a8f11df328edfbc1754cef7d94585a582872ddf7"
"f0ad5594bf6107389cb8b3dfdfff1425e3317b16"
"d7492a0be885ea9f2b9f71e3e95582f9a859c439"
"3beecafc2cae86290a191c1e841be13f5b08795d"
"e8c3872555fc85640505974e6b1c39d315572689"
"ff323b2a5c56cdec93900af4d67f3811f946d9b8"
"fa21985a7a2f8f52a8bd82bd12a724e9dca74934"
"a11b9ca01cef170d232c6b99bef86a52a9710df9"
"1199f1a4aac3946cb427f2bed73948b02ee14a74"
```

If we are interested in more fields, we can separate the filters with comma:

`cat commits.json | jq '.[] | .sha,.url'`

The command above will get both **sha** and **url** from each commit:

```
"726f2e59f9b0c7a69f540e09bab54ab17b013d56"
"https://api.github.com/repos/ruby/ruby/commits/726f2e59f9b0c7a69f540e09bab54ab17b013d56"
"a8f11df328edfbc1754cef7d94585a582872ddf7"
"https://api.github.com/repos/ruby/ruby/commits/a8f11df328edfbc1754cef7d94585a582872ddf7"
"f0ad5594bf6107389cb8b3dfdfff1425e3317b16"
"https://api.github.com/repos/ruby/ruby/commits/f0ad5594bf6107389cb8b3dfdfff1425e3317b16"
"d7492a0be885ea9f2b9f71e3e95582f9a859c439"
"https://api.github.com/repos/ruby/ruby/commits/d7492a0be885ea9f2b9f71e3e95582f9a859c439"
"3beecafc2cae86290a191c1e841be13f5b08795d"
"https://api.github.com/repos/ruby/ruby/commits/3beecafc2cae86290a191c1e841be13f5b08795d"
"e8c3872555fc85640505974e6b1c39d315572689"
"https://api.github.com/repos/ruby/ruby/commits/e8c3872555fc85640505974e6b1c39d315572689"
"ff323b2a5c56cdec93900af4d67f3811f946d9b8"
"https://api.github.com/repos/ruby/ruby/commits/ff323b2a5c56cdec93900af4d67f3811f946d9b8"
"fa21985a7a2f8f52a8bd82bd12a724e9dca74934"
"https://api.github.com/repos/ruby/ruby/commits/fa21985a7a2f8f52a8bd82bd12a724e9dca74934"
"a11b9ca01cef170d232c6b99bef86a52a9710df9"
"https://api.github.com/repos/ruby/ruby/commits/a11b9ca01cef170d232c6b99bef86a52a9710df9"
"1199f1a4aac3946cb427f2bed73948b02ee14a74"
"https://api.github.com/repos/ruby/ruby/commits/1199f1a4aac3946cb427f2bed73948b02ee14a74"
```

What if we wanted to construct a new JSON array with the output of the last command? Let's see how it's done:

`cat commits.json | jq '.[] | { sha: .sha, url: .url }' | jq -s`

Piping the result to `jq -s`, instead of running the filter for each JSON object in the input, it reads the entire input stream into a large array and runs the filter only once. And the result is this:

```
[
  {
    "sha": "726f2e59f9b0c7a69f540e09bab54ab17b013d56",
    "url": "https://api.github.com/repos/ruby/ruby/commits/726f2e59f9b0c7a69f540e09bab54ab17b013d56"
  },
  {
    "sha": "a8f11df328edfbc1754cef7d94585a582872ddf7",
    "url": "https://api.github.com/repos/ruby/ruby/commits/a8f11df328edfbc1754cef7d94585a582872ddf7"
  },
  {
    "sha": "f0ad5594bf6107389cb8b3dfdfff1425e3317b16",
    "url": "https://api.github.com/repos/ruby/ruby/commits/f0ad5594bf6107389cb8b3dfdfff1425e3317b16"
  },
  {
    "sha": "d7492a0be885ea9f2b9f71e3e95582f9a859c439",
    "url": "https://api.github.com/repos/ruby/ruby/commits/d7492a0be885ea9f2b9f71e3e95582f9a859c439"
  },
  {
    "sha": "3beecafc2cae86290a191c1e841be13f5b08795d",
    "url": "https://api.github.com/repos/ruby/ruby/commits/3beecafc2cae86290a191c1e841be13f5b08795d"
  },
  {
    "sha": "e8c3872555fc85640505974e6b1c39d315572689",
    "url": "https://api.github.com/repos/ruby/ruby/commits/e8c3872555fc85640505974e6b1c39d315572689"
  },
  {
    "sha": "ff323b2a5c56cdec93900af4d67f3811f946d9b8",
    "url": "https://api.github.com/repos/ruby/ruby/commits/ff323b2a5c56cdec93900af4d67f3811f946d9b8"
  },
  {
    "sha": "fa21985a7a2f8f52a8bd82bd12a724e9dca74934",
    "url": "https://api.github.com/repos/ruby/ruby/commits/fa21985a7a2f8f52a8bd82bd12a724e9dca74934"
  },
  {
    "sha": "a11b9ca01cef170d232c6b99bef86a52a9710df9",
    "url": "https://api.github.com/repos/ruby/ruby/commits/a11b9ca01cef170d232c6b99bef86a52a9710df9"
  },
  {
    "sha": "1199f1a4aac3946cb427f2bed73948b02ee14a74",
    "url": "https://api.github.com/repos/ruby/ruby/commits/1199f1a4aac3946cb427f2bed73948b02ee14a74"
  }
]
```

Jq has awesome feature for applying conditional logic, too. Let's assume we were interested in getting only the commits that have comments. Jq makes this super easy:

`cat commits.json | jq '.[] | select(.commit.comment_count > 0)'`

There are lots of features in jq and we have only scratched the surface. If you are interested in this awesome tool, head over to the <a href="https://stedolan.github.io/jq/manual/" target="_blank" rel="noopener nofollow">documentation</a> and find out more.

That's all for now!
