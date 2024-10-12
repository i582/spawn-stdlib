# `backtrace` module

`backtrace` module provides functionality to capture, trace, and resolve
stack backtraces for OS threads.

It allows you to inspect the current call-stack, capture stack traces, and
resolve program counters to more meaningful frame information such as function
names and line numbers.

## Overview

The `Backtrace` struct represents a stack backtrace for an OS thread captured at
a previous point in time.

> At this point, if you use functions from this module, you need to compile
> the program with the `--backtrace full` flag!

Stacktrace can be captured with `backtrace.capture()` function:

```spawn
module main

import backtrace

fn foo() {
    bt := backtrace.capture().unwrap()
    for frame in bt.frames(skip: 0) {
        println(frame.demangled_name())
    }
}

fn main() {
    foo()
}
```

To obtain a stacktrace frame-by-frame, use the `backtrace.trace()` function:

```spawn
module main

import backtrace

fn foo() {
    backtrace.trace(fn (f backtrace.RawFrame) -> bool {
        backtrace.resolve_frame(f, fn (s backtrace.ResolvedFrame) -> bool {
            println(s.demangled_name())
            return true
        })
        return true
    })
}

fn main() {
    foo()
}
```

To print current stacktrace to stderr use `backtrace.display()` function:

```spawn
module main

import backtrace

fn foo() {
    backtrace.display(skip: 0)
}

fn main() {
    foo()
}
```
