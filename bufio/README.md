# `bufio` module

The `bufio` module provides buffered I/O functionality to improve the
performance of read operations by reducing the number of underlying read
operations that may require long syscalls.

This module includes the `Reader` struct and related functions to add buffering
to any reader. See `Reader` struct documentation for more details.

To create a new buffered reader use `bufio.reader()` function:

```spawn
import fs
import bufio

fn main() {
    file := fs.open_file('main.sp', 'r').unwrap()
    reader := bufio.reader(file)
    line, is_prefix := reader.read_line().unwrap()
    println('Length of first line is ${line.len}, is_prefix: ${is_prefix}')
}
```

Buffered reader with custom capacity can be created with `bufio.reader_sized()`
function:

```spawn
import fs
import bufio

fn main() {
    file := fs.open_file('main.sp', 'r').unwrap()
    reader := bufio.reader_sized(file, 100)
    line, is_prefix := reader.read_line().unwrap()
    println('Length of first line is ${line.len}, is_prefix: ${is_prefix}')
}
```
