const std = @import("std");
const testing = std.testing;
const vk = @import("vulkan");
const vma = vk.vma;

test "vma module is accessible" {
    _ = vma.Allocator;
    _ = vma.Allocation;
    _ = vma.VirtualBlock;
}

test "MemoryUsage enum values" {
    try testing.expectEqual(@as(c_int, 0), @intFromEnum(vma.MemoryUsage.unknown));
    try testing.expectEqual(@as(c_int, 1), @intFromEnum(vma.MemoryUsage.gpu_only));
    try testing.expectEqual(@as(c_int, 2), @intFromEnum(vma.MemoryUsage.cpu_only));
    try testing.expectEqual(@as(c_int, 3), @intFromEnum(vma.MemoryUsage.cpu_to_gpu));
    try testing.expectEqual(@as(c_int, 4), @intFromEnum(vma.MemoryUsage.gpu_to_cpu));
    try testing.expectEqual(@as(c_int, 5), @intFromEnum(vma.MemoryUsage.cpu_copy));
    try testing.expectEqual(@as(c_int, 6), @intFromEnum(vma.MemoryUsage.gpu_lazily_allocated));
    try testing.expectEqual(@as(c_int, 7), @intFromEnum(vma.MemoryUsage.auto));
    try testing.expectEqual(@as(c_int, 8), @intFromEnum(vma.MemoryUsage.auto_prefer_device));
    try testing.expectEqual(@as(c_int, 9), @intFromEnum(vma.MemoryUsage.auto_prefer_host));
}

test "DefragmentationMoveOperation enum values" {
    try testing.expectEqual(@as(c_int, 0), @intFromEnum(vma.DefragmentationMoveOperation.copy));
    try testing.expectEqual(@as(c_int, 1), @intFromEnum(vma.DefragmentationMoveOperation.ignore));
    try testing.expectEqual(@as(c_int, 2), @intFromEnum(vma.DefragmentationMoveOperation.destroy));
}

test "AllocatorCreateFlags bit values" {
    try testing.expectEqual(@as(u32, 0x00000001), (vma.AllocatorCreateFlags{ .externally_synchronized_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000002), (vma.AllocatorCreateFlags{ .khr_dedicated_allocation_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000004), (vma.AllocatorCreateFlags{ .khr_bind_memory2_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000008), (vma.AllocatorCreateFlags{ .ext_memory_budget_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000010), (vma.AllocatorCreateFlags{ .amd_device_coherent_memory_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000020), (vma.AllocatorCreateFlags{ .buffer_device_address_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000040), (vma.AllocatorCreateFlags{ .ext_memory_priority_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000080), (vma.AllocatorCreateFlags{ .khr_maintenance4_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000100), (vma.AllocatorCreateFlags{ .khr_maintenance5_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0), (vma.AllocatorCreateFlags{}).toInt());
}

test "AllocationCreateFlags bit values" {
    try testing.expectEqual(@as(u32, 0x00000001), (vma.AllocationCreateFlags{ .dedicated_memory_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000002), (vma.AllocationCreateFlags{ .never_allocate_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000004), (vma.AllocationCreateFlags{ .mapped_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000040), (vma.AllocationCreateFlags{ .upper_address_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000080), (vma.AllocationCreateFlags{ .dont_bind_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000100), (vma.AllocationCreateFlags{ .within_budget_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000200), (vma.AllocationCreateFlags{ .can_alias_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000400), (vma.AllocationCreateFlags{ .host_access_sequential_write_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00000800), (vma.AllocationCreateFlags{ .host_access_random_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00001000), (vma.AllocationCreateFlags{ .host_access_allow_transfer_instead_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00010000), (vma.AllocationCreateFlags{ .strategy_min_memory_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00020000), (vma.AllocationCreateFlags{ .strategy_min_time_bit = true }).toInt());
    try testing.expectEqual(@as(u32, 0x00040000), (vma.AllocationCreateFlags{ .strategy_min_offset_bit = true }).toInt());
}

test "flags roundtrip" {
    const flags = vma.AllocationCreateFlags{
        .dedicated_memory_bit = true,
        .mapped_bit = true,
    };
    const int_val = flags.toInt();
    try testing.expectEqual(@as(u32, 0x05), int_val);
    const back = vma.AllocationCreateFlags.fromInt(int_val);
    try testing.expect(back.dedicated_memory_bit);
    try testing.expect(back.mapped_bit);
    try testing.expect(!back.never_allocate_bit);
}

test "VulkanFunctions default is zeroed" {
    const fns = vma.VulkanFunctions{};
    const bytes = std.mem.asBytes(&fns);
    for (bytes) |b| {
        try testing.expectEqual(@as(u8, 0), b);
    }
}

test "AllocationCreateInfo default" {
    const info = vma.AllocationCreateInfo{};
    try testing.expectEqual(vma.MemoryUsage.auto, info.usage);
    try testing.expectEqual(@as(u32, 0), info.flags.toInt());
}

// Virtual Block tests — no GPU required.

test "virtual block: create and destroy" {
    const block = try vma.createVirtualBlock(.{ .size = 1024 * 1024 });
    defer vma.destroyVirtualBlock(block);
    try testing.expect(vma.isVirtualBlockEmpty(block));
}

test "virtual block: allocate and free" {
    const block = try vma.createVirtualBlock(.{ .size = 1024 * 1024 });
    defer vma.destroyVirtualBlock(block);

    const result = try vma.virtualAllocate(block, .{ .size = 256 });
    try testing.expect(!vma.isVirtualBlockEmpty(block));

    vma.virtualFree(block, result.allocation);
    try testing.expect(vma.isVirtualBlockEmpty(block));
}

test "virtual block: multiple allocations with statistics" {
    const block = try vma.createVirtualBlock(.{ .size = 1024 * 1024 });
    defer vma.destroyVirtualBlock(block);

    const a1 = try vma.virtualAllocate(block, .{ .size = 256 });
    const a2 = try vma.virtualAllocate(block, .{ .size = 512 });
    const a3 = try vma.virtualAllocate(block, .{ .size = 1024 });

    var stats: vma.Statistics = undefined;
    vma.getVirtualBlockStatistics(block, &stats);
    try testing.expectEqual(@as(u32, 1), stats.block_count);
    try testing.expectEqual(@as(u32, 3), stats.allocation_count);

    vma.virtualFree(block, a2.allocation);

    vma.getVirtualBlockStatistics(block, &stats);
    try testing.expectEqual(@as(u32, 2), stats.allocation_count);

    vma.virtualFree(block, a1.allocation);
    vma.virtualFree(block, a3.allocation);
    try testing.expect(vma.isVirtualBlockEmpty(block));
}

test "virtual block: allocation info retrieval" {
    const block = try vma.createVirtualBlock(.{ .size = 4096 });
    defer vma.destroyVirtualBlock(block);

    const alloc_size: vk.DeviceSize = 256;
    const result = try vma.virtualAllocate(block, .{ .size = alloc_size });
    defer vma.virtualFree(block, result.allocation);

    var info: vma.VirtualAllocationInfo = undefined;
    vma.getVirtualAllocationInfo(block, result.allocation, &info);
    try testing.expectEqual(alloc_size, info.size);
}

test "virtual block: alignment" {
    const block = try vma.createVirtualBlock(.{ .size = 4096 });
    defer vma.destroyVirtualBlock(block);

    const result = try vma.virtualAllocate(block, .{
        .size = 100,
        .alignment = 256,
    });
    defer vma.virtualFree(block, result.allocation);

    try testing.expectEqual(@as(vk.DeviceSize, 0), result.offset % 256);
}

test "virtual block: allocation failure when full" {
    const block = try vma.createVirtualBlock(.{ .size = 256 });
    defer vma.destroyVirtualBlock(block);

    const first = try vma.virtualAllocate(block, .{ .size = 256 });
    defer vma.virtualFree(block, first.allocation);

    const result = vma.virtualAllocate(block, .{ .size = 256 });
    try testing.expectError(vma.Error.OutOfDeviceMemory, result);
}

test "virtual block: user data" {
    const block = try vma.createVirtualBlock(.{ .size = 4096 });
    defer vma.destroyVirtualBlock(block);

    var my_data: u32 = 42;
    const result = try vma.virtualAllocate(block, .{
        .size = 128,
        .p_user_data = @ptrCast(&my_data),
    });
    defer vma.virtualFree(block, result.allocation);

    var info: vma.VirtualAllocationInfo = undefined;
    vma.getVirtualAllocationInfo(block, result.allocation, &info);
    const retrieved: *u32 = @ptrCast(@alignCast(info.p_user_data.?));
    try testing.expectEqual(@as(u32, 42), retrieved.*);
}

test "virtual block: clear all" {
    const block = try vma.createVirtualBlock(.{ .size = 4096 });
    defer vma.destroyVirtualBlock(block);

    _ = try vma.virtualAllocate(block, .{ .size = 100 });
    _ = try vma.virtualAllocate(block, .{ .size = 200 });
    _ = try vma.virtualAllocate(block, .{ .size = 300 });

    try testing.expect(!vma.isVirtualBlockEmpty(block));

    vma.clearVirtualBlock(block);

    try testing.expect(vma.isVirtualBlockEmpty(block));
}

test "virtual block: detailed statistics" {
    const block = try vma.createVirtualBlock(.{ .size = 4096 });
    defer {
        vma.clearVirtualBlock(block);
        vma.destroyVirtualBlock(block);
    }

    _ = try vma.virtualAllocate(block, .{ .size = 100 });
    _ = try vma.virtualAllocate(block, .{ .size = 200 });

    var stats: vma.DetailedStatistics = undefined;
    vma.calculateVirtualBlockStatistics(block, &stats);

    try testing.expectEqual(@as(u32, 2), stats.statistics.allocation_count);
    try testing.expect(stats.statistics.allocation_bytes >= 300);
    try testing.expect(stats.allocation_size_min <= 100);
    try testing.expect(stats.allocation_size_max >= 200);
}

test "virtual block: set and get user data after allocation" {
    const block = try vma.createVirtualBlock(.{ .size = 4096 });
    defer vma.destroyVirtualBlock(block);

    const result = try vma.virtualAllocate(block, .{ .size = 64 });
    defer vma.virtualFree(block, result.allocation);

    var tag: u64 = 0xDEAD_BEEF;
    vma.setVirtualAllocationUserData(block, result.allocation, @ptrCast(&tag));

    var info: vma.VirtualAllocationInfo = undefined;
    vma.getVirtualAllocationInfo(block, result.allocation, &info);
    const got: *u64 = @ptrCast(@alignCast(info.p_user_data.?));
    try testing.expectEqual(@as(u64, 0xDEAD_BEEF), got.*);
}

test "virtual block: many small allocations" {
    const block = try vma.createVirtualBlock(.{ .size = 1024 * 1024 });
    defer vma.destroyVirtualBlock(block);

    var allocs: [100]vma.VirtualAllocation = undefined;
    for (&allocs) |*a| {
        const result = try vma.virtualAllocate(block, .{ .size = 64 });
        a.* = result.allocation;
    }

    var stats: vma.Statistics = undefined;
    vma.getVirtualBlockStatistics(block, &stats);
    try testing.expectEqual(@as(u32, 100), stats.allocation_count);

    for (&allocs) |a| {
        vma.virtualFree(block, a);
    }
    try testing.expect(vma.isVirtualBlockEmpty(block));
}

test "virtual block: linear algorithm" {
    const block = try vma.createVirtualBlock(.{
        .size = 4096,
        .flags = .{ .linear_algorithm_bit = true },
    });
    defer vma.destroyVirtualBlock(block);

    const a1 = try vma.virtualAllocate(block, .{ .size = 100 });
    const a2 = try vma.virtualAllocate(block, .{ .size = 200 });

    // With linear algorithm, allocations should be sequential.
    try testing.expect(a2.offset > a1.offset);

    vma.clearVirtualBlock(block);
    try testing.expect(vma.isVirtualBlockEmpty(block));
}
