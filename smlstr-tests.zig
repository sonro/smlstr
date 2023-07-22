const std = @import("std");
const testing = std.testing;
const dbg = std.debug.print;

const SmlStr = @import("smlstr.zig").SmlStr;

test "create SmlStr from literal and append" {
    var str = try SmlStr(8).from("12345");
    try str.push('6');
    try str.pushStr("78");
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
}

test "append str to SmlStr with error" {
    var str = SmlStr(1).init();
    try str.push('c');
    try testing.expectError(error.Overflow, str.pushStr("s"));
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
