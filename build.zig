const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const maybe_registry = b.option(std.Build.LazyPath, "registry", "Set the path to the Vulkan registry (vk.xml)");
    const maybe_video = b.option(std.Build.LazyPath, "video", "Set the path to the Vulkan Video registry (video.xml)");
    const maybe_vulkan_include = b.option(std.Build.LazyPath, "vulkan_include", "Set the path to Vulkan headers include directory (for VMA)");
    const test_step = b.step("test", "Run all the tests");

    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Using the package manager, this artifact can be obtained by the user
    // through `b.dependency(<name in build.zig.zon>, .{}).artifact("vulkan-zig-generator")`.
    // with that, the user need only `.addArg("path/to/vk.xml")`, and then obtain
    // a file source to the generated code with `.addOutputArg("vk.zig")`
    const generator_exe = b.addExecutable(.{
        .name = "vulkan-zig-generator",
        .root_module = root_module,
    });
    b.installArtifact(generator_exe);

    // Pass `.registry` and `.vulkan_include` to `b.dependency` to get the `"vulkan-zig"` module
    // with VMA included. The generated vk.zig re-exports VMA as `@import("vulkan").vma`.
    //
    // Usage:
    //   const vulkan_headers = b.dependency("vulkan_headers", .{});
    //   const vulkan = b.dependency("vulkan_zig", .{
    //       .registry = vulkan_headers.path("registry/vk.xml"),
    //       .vulkan_include = vulkan_headers.path("include"),
    //   }).module("vulkan-zig");
    //   exe.root_module.addImport("vulkan", vulkan);
    //
    // Then in Zig: const vk = @import("vulkan"); const vma = vk.vma;
    if (maybe_registry) |registry| {
        const vulkan_include = maybe_vulkan_include orelse
            @panic("vulkan_include is required when registry is provided");

        const vk_generate_cmd = b.addRunArtifact(generator_exe);

        if (maybe_video) |video| {
            vk_generate_cmd.addArg("--video");
            vk_generate_cmd.addFileArg(video);
        }

        vk_generate_cmd.addFileArg(registry);

        const vk_zig = vk_generate_cmd.addOutputFileArg("vk.zig");

        // Build VMA as a static C++ library.
        const vma_root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        });
        vma_root_module.addCSourceFile(.{
            .file = b.path("src/vma/vk_mem_alloc.cpp"),
            .flags = &.{"-std=c++17"},
        });
        vma_root_module.addIncludePath(vulkan_include);
        vma_root_module.addIncludePath(b.path("src/vma"));

        const vma_lib = b.addLibrary(.{
            .name = "vma",
            .root_module = vma_root_module,
        });
        b.installArtifact(vma_lib);

        // Create the VMA Zig wrapper module.
        const vma_module = b.createModule(.{
            .root_source_file = b.path("src/vma/vma.zig"),
            .target = target,
            .optimize = optimize,
        });
        vma_module.addIncludePath(vulkan_include);
        vma_module.addIncludePath(b.path("src/vma"));
        vma_module.linkLibrary(vma_lib);

        // Create the vulkan-zig module with VMA as a sub-import.
        // The generated vk.zig contains `pub const vma = @import("vma");`
        // so users access VMA via `@import("vulkan").vma`.
        const vk_zig_module = b.addModule("vulkan-zig", .{
            .root_source_file = vk_zig,
        });
        vk_zig_module.addImport("vma", vma_module);

        // Also install vk.zig, if passed.
        const vk_zig_install_step = b.addInstallFile(vk_zig, "src/vk.zig");
        b.getInstallStep().dependOn(&vk_zig_install_step.step);

        // And run tests on this vk.zig too.

        // This test needs to be an object so that vulkan-zig can import types from the root.
        // It does not need to run anyway.
        const ref_all_decls_test = b.addObject(.{
            .name = "ref-all-decls-test",
            .root_module = b.createModule(.{
                .root_source_file = b.path("test/ref_all_decls.zig"),
                .target = target,
                .optimize = optimize,
            }),
        });
        ref_all_decls_test.root_module.addImport("vulkan", vk_zig_module);
        test_step.dependOn(&ref_all_decls_test.step);
    }

    const test_target = b.addTest(.{ .root_module = root_module });
    test_step.dependOn(&b.addRunArtifact(test_target).step);
}
