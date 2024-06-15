const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Expose to dependents
    const module = b.addModule("smlstr", .{
        .root_source_file = b.path("smlstr.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addStaticLibrary(.{
        .name = "smlstr",
        .root_source_file = b.path("smlstr.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // tests
    const tests = b.addTest(.{
        .root_source_file = b.path("smlstr-tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    tests.root_module.addImport("smlstr", module);

    const run_main_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
