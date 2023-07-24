const std = @import("std");

/// Small string buffer where `capacity` is fixed.
///
/// `capacity` must be `> 1`.
///
/// ## Uses
///
/// - Constructing a string where max-size is known.
/// - Building an adhoc string without using an allocator.
/// - Passing a small string around the stack.
///
/// ## Methods
///
/// - `from` to create from an existing string.
/// - `init` for an empty string.
/// - `pop` to remove the last character.
/// - `push` to append a single character.
/// - `pushStr` to append another string.
/// - `pushFmt` to append a formatted string.
/// - `slice` to represent as a `[]const u8`
///
/// ## Errors
///
/// `SmlStrError.Overflow` -  If creating or pushing would overflow
/// the internal buffer.
///
/// ## Unbound
///
/// `from`, `push` and `pushStr` have unbound versions:
/// - `ubFrom`
/// - `ubPush`
/// - `ubPushStr`
///
/// These will cause a panic if they overflow the buffer.
///
/// ## Examples
///
/// ### Basic
///
/// ```zig
/// var str = try SmlStr(16).from("hello");
/// try str.push(',');
/// try str.pushStr(" world!");
/// print("{s}", .{str.slice()});
/// ```
///
/// ### Formatting
///
/// ```zig
/// var str = SmlStr(64).init();
/// for (0..32) |i| {
///     try str.pushFmt("{}", .{i});
/// }
/// ```
///
/// ### Conditional string building
///
/// ```zig
/// const FILE_CHAR = "abcdefgh";
/// const RANK_CHAR = "12345678";
///
/// fn idxFileRankStr(idx: usize) SmlStr(2) {
///     // initialize an empty string
///     var str = SmlStr(2).init();
///     // conditional string building
///     if (idx < 64) {
///         // we use unbound push as we are sure we don't overflow
///         str.ubPush(FILE_CHAR[idx % 8]);
///         str.ubPush(RANK_CHAR[idx / 8]);
///     } else {
///         str.ubPush('-');
///     }
///     return str;
/// }
/// ```
pub fn SmlStr(comptime capacity: comptime_int) type {
    std.debug.assert(capacity > 0);
    return struct {
        /// Internal buffer
        buf: [capacity]u8 = undefined,
        /// Current length of string within buffer
        len: usize = 0,

        const Self = @This();

        /// Create an empty `SmlStr`.
        pub inline fn init() Self {
            return Self{};
        }

        /// As a string slice.
        ///
        /// Useful for formatting and coercing into functions.
        ///
        /// ## Example
        /// ```zig
        /// const str = SmlStr(8).from("hi there");
        /// // use in formatting
        /// std.debug.print("{s}\n", .{str.slice()});
        /// // pass as function arg
        /// var words = std.mem.splitScalar(u8, str.slice(), ' ');
        /// ```
        pub inline fn slice(self: *const Self) []const u8 {
            return self.buf[0..self.len];
        }

        /// Create a `SmlStr` from copying an existing string.
        ///
        /// ## Errors
        ///
        /// `SmlStrError.Overflow` existing string larger than `SmlStr` capacity.
        pub fn from(str: []const u8) SmlStrError!Self {
            if (str.len > capacity) return SmlStrError.Overflow;
            return Self.ubFrom(str);
        }

        /// Remove the last char from the `SmlStr`.
        /// Returns the removed char or null if empty.
        pub fn pop(self: *Self) ?u8 {
            if (self.len == 0) return null;
            self.len -= 1;
            return self.buf[self.len];
        }

        /// Append a single char to the `SmlStr`
        ///
        /// ## Errors
        ///
        /// `SmlStrError.Overflow` string can grow no larger.
        pub fn push(self: *Self, char: u8) SmlStrError!void {
            if (self.len == capacity) return SmlStrError.Overflow;
            self.ubPush(char);
        }

        /// Append a string slice to the `SmlStr`.
        ///
        /// ## Errors
        ///
        /// `SmlStrError.Overflow` string slice won't fit into SmlStr.
        pub fn pushStr(self: *Self, str: []const u8) SmlStrError!void {
            const newlen = self.len + str.len;
            if (newlen > capacity) return SmlStrError.Overflow;
            @memcpy(self.buf[self.len..newlen], str);
            self.len = newlen;
        }

        /// Append a formatted string to the `SmlStr`.
        ///
        /// ## Errors
        ///
        /// `SmlStrError.Overflow` string slice won't fit into SmlStr.
        pub fn pushFmt(self: *Self, comptime fmt: []const u8, args: anytype) SmlStrError!void {
            const written = std.fmt.bufPrint(self.buf[self.len..], fmt, args) catch |err| {
                switch (err) {
                    std.fmt.BufPrintError.NoSpaceLeft => return SmlStrError.Overflow,
                }
            };
            self.len += written.len;
        }

        /// Create a `SmlStr` from copying an existing string.
        ///
        /// Panics on overflow.
        pub fn ubFrom(str: []const u8) Self {
            var self = Self{ .len = str.len };
            @memcpy(self.buf[0..str.len], str);
            return self;
        }

        /// Append a single char to the `SmlStr`.
        ///
        /// Panics on overflow.
        pub fn ubPush(self: *Self, char: u8) void {
            self.buf[self.len] = char;
            self.len += 1;
        }

        /// Append a string slice to the `SmlStr`.
        ///
        /// Panics on overflow.
        pub fn ubPushStr(self: *Self, str: []const u8) void {
            const newlen = self.len + str.len;
            @memcpy(self.buf[self.len..newlen], str);
            self.len = newlen;
        }
    };
}

/// Create a `SmlStr` from copying a `comptime` string slice.
/// Its capacity will be equal to the string's length.
pub fn smlStrFrom(comptime str: []const u8) SmlStr(str.len) {
    return SmlStr(str.len).ubFrom(str);
}

/// Create a `SmlStr` from copying a `comptime` string slice.
/// Its capacity will be equal to the string's length + `extra`.
pub fn smlStrWith(
    comptime str: []const u8,
    comptime extra: usize,
) SmlStr(str.len + extra) {
    return SmlStr(str.len + extra).ubFrom(str);
}

/// Create a `SmlStr` from copying two `comptime` string slices.
/// Its capacity will be the sum of their lengths.
pub fn smlStrConcat(
    comptime a: []const u8,
    comptime b: []const u8,
) SmlStr(a.len + b.len) {
    var str = SmlStr(a.len + b.len).ubFrom(a);
    str.ubPushStr(b);
    return str;
}

/// Create a `SmlStr` with a capacity equal to the length of the example string.
/// The example string is *NOT* copied in.
pub fn smlStrSizeOf(comptime example: []const u8) SmlStr(example.len) {
    return SmlStr(example.len).init();
}

pub const SmlStrError = error{
    /// Operation would overflow `SmlStr` capacity.
    Overflow,
};
