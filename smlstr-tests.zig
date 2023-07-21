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

test "append SmlStr with error" {
    var str = SmlStr(1).init();
    try str.push('c');
    try testing.expectError(error.Overflow, str.push('c'));
}
