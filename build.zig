const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Expose to dependents
    const module = b.addModule("smlstr", .{
        .source_file = .{ .path = "smlstr.zig" },
        .dependencies = &.{},
    });

    const lib = b.addStaticLibrary(.{
        .name = "smlstr",
        .root_source_file = .{ .path = "smlstr.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.addModule("smlstr", module);
    b.installArtifact(lib);

    // tests
    const tests = b.addTest(.{
        .root_source_file = .{ .path = "smlstr-tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    tests.addModule("smlstr", module);

    const run_main_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
