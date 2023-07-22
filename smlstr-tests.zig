const std = @import("std");
const testing = std.testing;
const dbg = std.debug.print;

const smlstr = @import("smlstr.zig");
const SmlStr = smlstr.SmlStr;
const smlStrFrom = smlstr.smlStrFrom;
const smlStrWith = smlstr.smlStrWith;
const smlStrConcat = smlstr.smlStrConcat;
const smlStrSizeOf = smlstr.smlStrSizeOf;

test "create SmlStr from literal and append" {
    var str = try SmlStr(8).from("123");
    try str.push('4');
    try str.pushStr("56");
    _ = try str.pushFmt("{s}", .{"78"});
    try testing.expectEqualStrings("12345678", str.slice());
}

test "create SmlStr from array" {
    const array = [4]u8{ '1', '2', '3', '4' };
    var str = try SmlStr(4).from(&array);
    try testing.expectEqualStrings("1234", str.slice());
}

test "create SmlStr from empty" {
    var str = try SmlStr(4).from("");
    try testing.expectEqualStrings("", str.slice());
}

test "create SmlStr with error" {
    try testing.expectError(error.Overflow, SmlStr(4).from("12345"));
}

test "append char to SmlStr with error" {
    var str = SmlStr(1).init();
    try str.push('c');
    try testing.expectError(error.Overflow, str.push('c'));
    try testing.expectEqualStrings("c", str.slice());
}

test "append str to SmlStr with error" {
    var str = SmlStr(1).init();
    try str.push('c');
    try testing.expectError(error.Overflow, str.pushStr("s"));
    try testing.expectEqualStrings("c", str.slice());
}

test "scoped pushStr" {
    var str = SmlStr(8).init();
    {
        var tmpstr: [5]u8 = undefined;
        for (0..5) |i| tmpstr[i] = @as(u8, @truncate(i)) + '0';
        try str.pushStr(&tmpstr);
    }
    try testing.expectEqualStrings("01234", str.slice());
}

test "append format string" {
    var str = SmlStr(64).init();
    const written = try str.pushFmt("test {s}", .{"string"});
    try testing.expectEqualStrings("test string", str.slice());
    try testing.expect(11 == written);
}

test "append format string with error" {
    var str = SmlStr(4).init();
    try testing.expectError(
        error.Overflow,
        str.pushFmt("test {s}", .{"string"}),
    );
    try testing.expectEqualStrings("", str.slice());
}

test "create a comptime SmlStr from a literal" {
    var str = smlStrFrom("test");
    try testing.expectEqualStrings("test", str.slice());
    try testing.expectError(error.Overflow, str.push('\n'));
}

test "create a comptime SmlStr with extra space" {
    var str = smlStrWith("test", 5);
    try testing.expectEqualStrings("test", str.slice());
    try str.pushStr(" test");
    try testing.expectEqualStrings("test test", str.slice());
}

test "create a comptime SmlStr via concat" {
    var str = smlStrConcat("hello", "world");
    try testing.expectEqualStrings("helloworld", str.slice());
    try testing.expectError(error.Overflow, str.push('\n'));
}

test "create an comptime SmlStr using an example string" {
    var str = smlStrSizeOf("hello, world");
    try testing.expect(str.len == 0);
    try str.pushStr("HELLO, WORLD");
    try testing.expectEqualStrings("HELLO, WORLD", str.slice());
    try testing.expectError(error.Overflow, str.push('\n'));
}

// UNCOMMENT TO TEST PANICS

// test "unbound from panics" {
//     _ = SmlStr(4).ubFrom("12345");
// }

// test "unbound push panics" {
//     var str = try SmlStr(1).from("0");
//     str.push('1');
// }

// test "unbound pushStr panics" {
//     var str = try SmlStr(1).from("0");
//     str.push("string");
// }
