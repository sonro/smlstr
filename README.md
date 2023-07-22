# smlstr

[![licence: MIT](https://img.shields.io/github/license/sonro/smlstr)](https://github.com/sonro/smlstr/blob/main/LICENSE)
[![release](https://img.shields.io/github/v/release/sonro/smlstr)](https://github.com/sonro/smlstr/releases/latest)

Small Zig library for working with small strings.

- [Use cases](#use-cases)
- [Usage](#usage)
  - [Functions](#functions)
  - [Error](#errors)
  - [Unbound](#unbound)
  - [Importing into a Zig project](#importing-into-a-zig-project)
- [Contributing](#contributing)
- [License](#license)

## Use Cases

- Constructing a string where max-size is known.
- Building an adhoc string without using an allocator.
- Passing a small string around the stack.

If you require a large string, or you want to dynamically grow the underlying
string buffer, use the Zig standard library's
[`ArrayList(u8)`](https://ziglang.org/documentation/master/std/#A;std:ArrayList).

## Usage

This library exposes the type `SmlStr` through a generic `comptime fn`
(see [Zig docs](https://ziglang.org/documentation/master/#Generic-Data-Structures)).

The capacity of the string is part of its type.  Use an integer greater than `0`
to denote the type i.e. `SmlStr(16)` can hold a maximum of `16` `u8` characters.

Example in a function return type:

```zig
fn createDebugString(data: Data) !SmlStr(32) {
    ...
}
```

### Functions

- `from` to create from an existing string.

  ```zig
  var str = try SmlStr(16).from("string literal");
  ```

  ```zig
  var str = try SmlStr(16).from(existing_var);
  std.testing.expect(str.len == existing_var.len);
  std.testing.expectEqualStrings(existing_var, str.slice());
  ```

- `init` for an empty string.

  ```zig
  var str = SmlStr(8).init()
  std.testing.expect(str.len == 0);
  ```

- `push` to append a single character.

  ```zig
  var str = SmlStr(4).init()
  try str.push(char);
  std.testing.expect(str.len == 1);
  ```

- `pushStr` to append another string.

  ```zig
  var str = try SmlStr(16).from("hello")
  try str.pushStr(", world");
  std.testing.expectEqualStrings("hello, world", str.slice());
  ```

- `pushFmt` to append a formatted string.

  ```zig
  var str = try SmlStr(64).init();
  const written = try str.pushFmt("hello, {s}", .{"world"});
  try std.testing.expect(11 == written);
  try std.testing.expectEqualStrings("hello, world", str.slice());
  ```

- `slice` to represent as a `[]const u8`

  ```zig
  const str = SmlStr(8).from("hi there");
  // use in formatting
  std.debug.print("{s}\n", .{str.slice()});
  // pass as function arg
  var words = std.mem.splitScalar(u8, str.slice(), ' ');
  ```

### Errors

`SmlStrError.Overflow` -  If creating or pushing would overflow
the internal buffer.

### Unbound

`from`, `push` and `pushStr` have unbound versions which will not error:

- `ubFrom`
- `ubPush`
- `ubPushStr`

These will cause a panic if they overflow the buffer, useful if you know that's
not possible.

#### Unbound example

```zig
const FILE_CHAR = "abcdefgh";
const RANK_CHAR = "12345678";

fn idxFileRankStr(idx: usize) SmlStr(2) {
    // initialize an empty string
    var str = SmlStr(2).init();
    // conditional string building
    if (idx < 64) {
        // we use unbound push as we are sure we don't overflow
        str.ubPush(FILE_CHAR[idx % 8]);
        str.ubPush(RANK_CHAR[idx / 8]);
    } else {
        str.ubPush('-');
    }
    return str;
}
```

### Importing into a Zig Project

To add to your Zig project, create a `lib/` directory and either:

- download this repo straight into `lib/smlstr`
- add it as a git submodule with:

  ```bash
  git submodule add -b main https://github.com/sonro/smlstr.git lib/smlstr
  ```

Add it as a module in your `build.zig`:

```diff
 // build.zig
 const std = @import("std");

 pub fn build(b: *std.Build) void {
...
 
+    const smlstr_mod = b.addModule("shared", .{ .source_file = .{
+       .path = "lib/smlstr/smlstr.zig",
+    } });
...

     // executable
     const exe = b.addExecutable(.{
        ...
     });


+    exe.addModule("smlstr", smlstr_mod);
...

     // tests
     const unit_tests = b.addTest(.{
        ...
     });

+    unit_tests.addModule("smlstr", smlstr_mod);
...
```

Make sure you use it to test it's working:

```zig
// main.zig
const std = @import("std");
const SmlStr = @import("smlstr").SmlStr;

// prints hello world
pub fn main() !void {
    var str = try SmlStr(16).from("hello");
    try str.pushStr(", world!");
    std.debug.print("{s}", .{str.slice()});
}
```

#### Updating Git Submodule

```bash
git submodule update --recursive --remote
```

## Contributing

Thank you very much for considering to contribute to this project!

We welcome any form of contribution:

- New issues (feature requests, bug reports, questions, ideas, ...)
- Pull requests (documentation improvements, code improvements, new features, ...)

Note: Before you take the time to open a pull request, please open an issue first.

## License

This project is licensed under the [MIT license](/LICENSE).
