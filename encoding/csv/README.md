# `csv` module

`csv` module provides functions for reading files in CSV format.

To create a new reader, use the `csv.Reader.new()` or `csv.Reader.from_string()`
method, the first accepts any type implementing `io.Reader` (for example
`fs.File`), and second accepts a string.

Example of reading all records from a file:

```spawn
module main

import fs
import encoding.csv

fn main() {
    file := fs.open_file("file.csv", "r").unwrap()
    mut r := csv.Reader.new(file)
    records := r.read_all().unwrap()
    println(records)
}
```

The created reader can be customized by setting custom values to the following
fields. For more information, see the comments on these fields.

| Field                | Description                                                                      |
|----------------------|----------------------------------------------------------------------------------|
| `comma`              | Sets the separator                                                               |
| `comment`            | If the line starts with this character, it is considered a comment               |
| `fields_per_record`  | Sets the expected number of fields or disables checking for the number of fields |
| `trim_leading_space` | If set to true, the reader will skip all spaces and tabs before the value        |

For example:

```spawn
module main

import fs
import encoding.csv

fn main() {
    file := fs.open_file("file.csv", "r").unwrap()
    mut r := csv.Reader.new(file)
    r.comma = b`;`
    r.comment = b`#`
    r.trim_leading_space = true
    records := r.read_all().unwrap()
    println(records)
}
```

Read the following file:

```csv
name;age
# Jo; 40
John; 20
Mark; 30
```

To the following array:

```
[
    ["name", "age"],
    ["John", "20"],
    ["Mark", "30"],
]
```

## Per record reading

This reader can be used to read even huge files, since it does not read the
entire file before parsing, but reads as needed.

To parse a file one record at a time, use the `csv.Reader.read_record()` method:

```spawn
module main

import fs
import encoding.csv

fn main() {
    file := fs.open_file("huge_file.csv", "r").unwrap()
    mut r := csv.Reader.new(file)
    for i in 0 .. 100 {
        record := r.read_record() or { break }
        println(record)
    }
}
```

In this example, we parse only the first 100 records from the file.

The same code can be written using the `csv.Reader.iter()` method, which returns
an iterator, this way is more preferable.

In this case, the iterator itself will take care of the case if there are fewer
than 100 records in the file.

```spawn
module main

import fs
import encoding.csv

fn main() {
    file := fs.open_file("huge_file.csv", "r").unwrap()
    mut r := csv.Reader.new(file)
    for i, record in r.iter() {
        if i > 100 {
            break
        }
        println(record)
    }
}
```

## Working with large files and `iter_view`

In addition to the usual iterator obtained via `Reader.iter`, the module also
provides a special iterator that does not allocate memory for each record
and work much faster.

On the one hand, this allows us to greatly speed up the iteration, on a file
with 100 million records, the speed increases more than two times, but on the
other hand, you need to be careful.

Main rule, under no circumstances save the record obtained from this iterator
somewhere to use it later after the current iteration. In this case, you will
end up with the wrong data, since the next iteration will overwrite the saved
data.

```spawn
import io
import encoding.csv

fn main() {
    mut r := csv.Reader.from_string("name,age\n1,2")
    mut last_record := csv.Record{}
    for record in r.iter_view() {
        // DON"T DO THIS
        last_record = record
    }
}
```

If you want to save the data from this record, call the `Record.as_array`
method, which will return a new array that can be safely assigned to a variable
outside the loop.

```spawn
import io
import encoding.csv

fn main() {
    mut r := csv.Reader.from_string("name,age\n1,2")
    mut last_record := []string{}
    for record in r.iter_view() {
        last_record = record.as_array() // ok
    }
}
```

Since the iteration goes by the view of records, then for even greater speed use
the method `Record.get_view` which will return a view on the string with the
value of this field. As in the case of the record, do not save this string
outside the loop. If you really need to save it use the method `Record.get`
which returns always valid string.
