---
title: 'Implementing a bit array in go'
published: 2020-09-13 11:00:00 +0300
tags: ['bitset', 'bit array', 'go']
---

A bit array (or bit set) is an array data structure that stores bits (0 or 1 value) in a space efficient, compact way (read more about bit arrays <a href="https://en.wikipedia.org/wiki/Bit_array" target="_blank" rel="noopener nofollow">on wikipedia</a>).

One of the most common uses of bit arrays is in probabilistic data structures (such as <a href="{% post_url 2020-08-29-bloom-filter-theory %}">Bloom filters</a>) for storing large amounts of data in a much more compact way. Another use would be saving configuration flags in a compact way. For example, file permissions in linux can be compactly stored using only 1 byte, by setting 3 bits (for read, write, execute), leading to 8 different combinations of permissions (2 _ 2 _ 2 for each flag).

Ok, so how would we implement a bit array in go? First of all, let's pick a data structure to store the array. A byte slice is ideal (since there is no bit data type), as we can perform operations on the individual bytes and each byte can store 8 bits. Let's see this in action:

```go showLineNumbers
package main

import (
	"fmt"
)

type BitArray struct {
	size int
	data []byte
}

func New(size int) BitArray {
	return BitArray{size: size, data: make([]byte, size/8+1)}
}

func (arr *BitArray) Set(position int) {
	arr.data[position/8] = arr.data[position/8] | (1 << (position % 8))
}

func (arr *BitArray) Unset(position int) {
	arr.data[position/8] = arr.data[position/8] & (255 ^ (1 << (position % 8)))
}

func (arr *BitArray) Get(position int) int {
	return arr.getBit(position)
}

func (arr *BitArray) getBit(position int) int {
	if arr.data[position/8]&(1<<(position%8)) > 0 {
		return 1
	} else {
		return 0
	}
}

func main() {
  arr := New(100)

  arr.Set(5)
  arr.Set(3)
  arr.Set(20)

  fmt.Printf("Bit %d = %d\n", 5, arr.Get(5)) // this will return "Bit 5 = 1"
  fmt.Printf("Bit %d = %d\n", 6, arr.Get(6)) // this will return "Bit 6 = 0"

  arr.Unset(5)
  fmt.Printf("Bit %d = %d\n", 5, arr.Get(5)) // this will return "Bit 5 = 0"
}
```

Let's see how the code works:

In **lines 7-10**, we define the struct that will store the bit array. The underlying data structure is a byte slice.

In **lines 12-14**, we have a constructor for the bit array. We specify the number of bits we want to store and we create a BitArray. The underlying byte slice will have a size of bits / 8 + 1. The extra byte is needed in case the bits are not a multiple of 8 (e.g. 10 bits will need 2 bytes. The second byte will store the last 2 bits' value)

In **lines 16-18**, we can Set a bit (i.e. make its value 1 / true). The operation here just gets the relevant byte and performs a bitwise OR with a bit mask to set the relevant bit of the byte to 1. For example, for position 4, we would update the first byte's value by applying a bit mask of 00010000 (1 << 4).

In **lines 20-22**, we can Unset a bit (i.e. make its value 0 / false). The operation performed is a bitwise AND that will make the value of the relevant bit zero. For example, for position 4, we would update the first byte's value by applying the mask 11101111 (255 ^ (1 << 4)).

Finally, in **lines 24-26**, we can Get the value of a bit. The operation is a bitwise AND with a mask that will keep the value of the n-th bit. For example, getting the bit in position 4, will apply the mask 00010000 to the first byte. If the value is greater than zero (meaning the bit is set), it returns 1, otherwise it returns 0. This is needed since the result of the bitwise operation will return 00010000 if the bit is set, which means the result will be 16. An alternative to the conditional implementation would be to divide by 1<<(position % 8) in order to get 1 or 0.

That's it! This is a simple implementation of a bit array. You can find a go module implementing the bit array (with a richer API and tests) <a href="https://github.com/m1lt0n/go-bitarray" target="_blank" rel="noopener nofollow">on github</a>.
