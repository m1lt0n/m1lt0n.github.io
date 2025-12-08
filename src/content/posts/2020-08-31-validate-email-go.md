---
title: 'Validating an email in go'
published: 2020-08-31 10:00:00 +0300
tags: ['go', 'email', 'validation']
---

Recently, I wanted to validate emails for a small project I work on. I didn't want to search for libraries that might do the job, so I decided to build the validation functions myself. My requirements were simple: I needed to validate the structure / format of the provided email address and to check the relevant DNS records for the domain of this email. For the format part of the email, I went with <a href="https://tools.ietf.org/html/rfc5322" target="_blank" rel="noopener nofollow">RFC 5322</a> compliance and for DNS records, I started out by checking the MX records of the email's domain.

This is what I ended up with:

```go
package main

import (
  "regexp"
  "net"
  "strings"
  "fmt"
)

var (
  emailRegexp = regexp.MustCompile(
    "(?i)(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"+
    "\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\["+
    "\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)"+
    "+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))"+
    "\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*"+
    "[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])")
)

func ValidateFormat(email string) bool {
  return emailRegexp.Match([]byte(email))
}

func  ValidateMx(email string) bool {
  if !ValidateFormat(email) {
    return false
  }

  emailParts := strings.Split(email, "@")
  mxRecords, err := net.LookupMX(emailParts[len(emailParts) - 1])

  return err == nil && len(mxRecords) > 0
}

func main() {
  fmt.Println(ValidateFormat("pvratsalis@this-is-invalid-email-by-m1lt0n.com"))
  fmt.Println(ValidateMx("pvratsalis@this-is-invalid-email-by-m1lt0.com"))
}
```

Let's go through the code. First, I compile (only once) the regular expression for a valid email (based on RFC 5322). Then, I have 2 functions that validate an email address. The first (`ValidateFormat`) just checks the validity of the email based on the regular expression. The second (`ValidateMx`), first checks that the format is valid and then performs a lookup for MX records for the domain of the email. If there is an error, or there are no MX records, the email is reported as invalid. This is by no means a bulletproof approach, but for my current needs it is sufficient.

As you can see in the main function, the `ValidateFormat` function reports the @this-is-invalid-email-by-m1lt0n.com email address as valid, while the `ValidateMx` function does not. Try it out with your email!

That's all for now!
