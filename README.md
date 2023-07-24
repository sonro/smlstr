# smlstr

[![licence: MIT](https://img.shields.io/github/license/sonro/smlstr)](https://github.com/sonro/smlstr/blob/main/LICENSE)
[![release](https://img.shields.io/github/v/release/sonro/smlstr)](https://github.com/sonro/smlstr/releases/latest)
[![tests](https://img.shields.io/github/actions/workflow/status/sonro/smlstr/tests.yml?logo=Zig&label=tests)](https://github.com/sonro/smlstr/actions/workflows/tests.yml)

Small Zig library for working with small strings.

- [Use cases](#use-cases)
- [Usage](#usage)
  - [Methods](#methods)
  - [Error](#errors)
  - [Unbound](#unbound)
  - [Comptime Functions](#comptime-functions)
- [Importing into a Zig project](#importing-into-a-zig-project)
  - [Package Manager](#zig-package-manager)
  - [Download Source](#download-source)
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

### Methods

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
  try std.testing.expect(str.len == 0);
  ```

- `pop` to remove the last character.

  ```zig
  var str = try SmlStr(4).from("a")
  try std.testing.expect('a' == str.pop());
  std.testing.expect(0 == str.len);
  // Returns `null` when `len` is `0`.
  try std.testing.expect(null == str.pop());
  ```

- `push` to append a single character.

  ```zig
  var str = SmlStr(4).init()
  try str.push(char);
  try std.testing.expect(str.len == 1);
  ```

- `pushStr` to append another string.

  ```zig
  var str = try SmlStr(16).from("hello")
  try str.pushStr(", world");
  try std.testing.expectEqualStrings("hello, world", str.slice());
  ```

- `pushFmt` to append a formatted string.

  ```zig
  var str = try SmlStr(64).init();
  try str.pushFmt("hello, {s}", .{"world"});
  try std.testing.expectEqualStrings("hello, world", str.slice());
  ```

- `slice` to represent as a `[]const u8`.

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

### Comptime Functions

All of these functions return a `SmlStr` with a capacity determined by their
arguments.

- `smlStrFrom` copying an existing string and capacity set to its length.

  ```zig
  // appending to this string will cause an overflow error
  const str = smlStrFrom("foobar");
  try std.testing.expectEqualStrings("foobar", str.slice());
  ```

- `smlStrWith` copying an existing string and capacity set to its length +
  defined extra space.

  ```zig
  var str = smlStrWith("answer: ", 2);
  var answer = 42;
  try str.pushFmt("{}", answer);
  try std.testing.expectEqualStrings("answer: 42", str.slice());
  ```

- `smlStrConcat` copying two existing strings and capacity set to the sum of
  their lengths.

  ```zig
  // appending to this string will cause an overflow error
  var str = smlStrConcat("hello", "there");
  try std.testing.expectEqualStrings("hellothere", str.slice());
  ```

- `smlStrSizeOf` capacity set to the example string's length without copying it.

  ```zig
  var str = smlStrSizeOf("General Kenobi");
  try std.testing.expect(0 == str.len);
  try str.pushStr("Luke Skywalker");
  try std.testing.expectEqualStrings("Luke Skywalker", str.slice());
  ```

## Importing into a Zig Project

To add this library to your project, either use Zig's internal package manager,
or download the source code (direct or git submodule). Then `@import` it
into your code to make sure it's working:

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

### Zig Package Manager

1. Add a `build.zig.zon` file to your project root:

    ```zig
    // build.zig.zon
    .{
        // the name of your project
        .name = "barfighter",
        .version = "0.1.0",

        .dependencies = .{
            // the name of the package
            .smlstr = .{
                // the url to the release of the module
                .url = "https://github.com/sonro/smlstr/archive/refs/tags/v0.2.1.tar.gz",
                // the hash of the module, this is not the checksum of the tarball
                .hash = "122054069f8488d6bb5b2214545c7659cd82ee08f728ced86c89365963d9ee7c3c11",
            },
            // ... other dependencies
        },
    }
    ```

2. Update your `build.zig` to add the library and module:

    ```diff
     // build.zig
     const std = @import("std");

     pub fn build(b: *std.Build) void {
     ...
    +    const smlstr = b.dependency("smlstr", .{
    +        .target = target,
    +        .optimize = optimize,
    +    });
    +    const smlstr_mod = smlstr.module("smlstr");

         // executable
         const exe = b.addExecutable(.{
             ...
         });

    +    exe.addModule("smlstr", smlstr_mod);
    +    exe.linkLibrary(smlstr.artifact("smlstr"));

         b.installArtifact(exe);
     ...

         // tests
         const unit_tests = b.addTest(.{
             ...
         });

    +    unit_tests.addModule("smlstr", smlstr_mod);

         const run_unit_tests = b.addRunArtifact(unit_tests);
     ...
    ```

### Download Source

1. Create a `lib` directory in your project root.

2. Either:
    - Direct download this repo into `lib/smlstr`.
    - Or add it as a git submodule with:

    ```bash
    git submodule add -b main https://github.com/sonro/smlstr.git lib/smlstr
    ```

3. Add it as a module in your `build.zig`:

    ```diff
     // build.zig
     const std = @import("std");

     pub fn build(b: *std.Build) void {
     ...
    +    const smlstr_mod = b.addModule("shared", .{ .source_file = .{
    +       .path = "lib/smlstr/smlstr.zig",
    +    } });

         // executable
         const exe = b.addExecutable(.{
             ...
         });

    +    exe.addModule("smlstr", smlstr_mod);
    
         b.installArtifact(exe);
    ...
        // tests
        const unit_tests = b.addTest(.{
            ...
        });

    +    unit_tests.addModule("smlstr", smlstr_mod);

         const run_unit_tests = b.addRunArtifact(unit_tests);
    ...
    ```

#### Updating Git Submodule

You can pull main branch again to update.

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
