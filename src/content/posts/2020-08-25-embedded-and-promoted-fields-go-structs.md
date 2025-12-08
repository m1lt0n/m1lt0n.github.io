---
title: 'Embedded and promoted fields in go structs'
published: 2020-08-25 09:00:00 +0300
tags: ['go', 'structs']
---

Structs are one of the most widely used data structures in go. Combined with interfaces and methods, structs allow us model our data in a way that is somehow similar to the object oriented paradigm's classes. Recently, I found out a couple interesting features of structs:

- embedded fields
- promoted fields

As you probably know, the usual way to declare a struct is similar to the following:

```go
type Person struct {
  name string
  gender string
}

me := Person{"Pantelis", "m"} // field is accessed as me.name
```

In the declaration above, the field names of the struct are provided explicitly and can be retrieved from the struct by that name (as shown in the example above).

Apart from the explicit naming of fields though, it is allowed to declare a struct by providing just the type of the field(s):

```go
type Person struct {
  T // T is some custom type
  *int
  name string
}
```

The first 2 fields are called _embedded_ fields. Embedded fields can be a type name T or a pointer to a non-interface type name \*T, and T itself may not be a pointer type (read more: <a href="https://golang.org/ref/spec#Struct_types" target="_blank" rel="noopener nofollow">golang.org</a>). How do we access embedded fields? by using the unqualified type name, so if we have a Person struct called person, we would access the T field as `person.T`. This means that we cannot have 2 embedded fields of the same type (e.g. two string fields), as field names should be unique in the context of a struct.

This brings us to _promoted fields_. Let's see an example:

```go
package main

import "fmt"

type Address struct {
  city string
  street string
}

type Person struct {
  name string
}

func (m Person) getName() string {
  return m.name
}

type Named interface {
  getName() string
}

type Employee struct {
  Named
  Address
}

func main() {
  me := Person{"Pantelis"}
  address := Address{"Athens", "Some street"}

  me_employee := Employee{me, address}

  fmt.Println(me_employee.Named.getName())
  fmt.Println(me_employee.getName()) // accessing promoted method
  fmt.Println(me_employee.city) // accessing promoted field
}
```

As we can see above, we create an `Employee` struct that has an embedded `Named` field. We can then access the fields and methods of the embedded fields of `Employee` as if they belonged to it. Those are called promoted methods and fields. Note that the promoted fields cannot be used in struct literals (i.e. we cannot create an Employee struct and set the city directly in a struct literal).

I will probably start using embedding and promoted fields in a web context in order to decorate entities and create view models. How about you?

That's all for now!
