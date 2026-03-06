//! Zig-native bindings for VMA (Vulkan Memory Allocator).
//!
//! All public types use native vulkan-zig types (`vk.Buffer`, `vk.BufferCreateInfo`,
//! etc.) rather than C Vulkan types. VMA is compiled as a C++17 static library
//! internally; the C layer is a private implementation detail.
//!
//! VMA is built with `VMA_STATIC_VULKAN_FUNCTIONS=0` and
//! `VMA_DYNAMIC_VULKAN_FUNCTIONS=0`. Use `vulkanFunctionsFromDispatch()` to
//! populate a `VulkanFunctions` struct from vulkan-zig dispatch tables when
//! creating an allocator.
//!
//! The Virtual Block API (`createVirtualBlock`, `virtualAllocate`, etc.) operates
//! entirely in CPU memory and does not require a Vulkan device.

const std = @import("std");
const vk = @import("vulkan");

const c = @cImport({
    @cDefine("VMA_STATIC_VULKAN_FUNCTIONS", "0");
    @cDefine("VMA_DYNAMIC_VULKAN_FUNCTIONS", "0");
    @cInclude("vk_mem_alloc.h");
});

// Error handling

pub const Error = error{
    OutOfHostMemory,
    OutOfDeviceMemory,
    InitializationFailed,
    FeatureNotPresent,
    TooManyObjects,
    Unknown,
};

inline fn checkResult(result: c.VkResult) Error!void {
    return switch (@as(vk.Result, @enumFromInt(result))) {
        .success => {},
        .error_out_of_host_memory => error.OutOfHostMemory,
        .error_out_of_device_memory => error.OutOfDeviceMemory,
        .error_initialization_failed => error.InitializationFailed,
        .error_feature_not_present => error.FeatureNotPresent,
        .error_too_many_objects => error.TooManyObjects,
        else => error.Unknown,
    };
}

// Flags helper — added directly on each packed struct below.

// Enums

pub const MemoryUsage = enum(c_int) {
    unknown = 0,
    gpu_only = 1,
    cpu_only = 2,
    cpu_to_gpu = 3,
    gpu_to_cpu = 4,
    cpu_copy = 5,
    gpu_lazily_allocated = 6,
    auto = 7,
    auto_prefer_device = 8,
    auto_prefer_host = 9,
    _,
};

pub const DefragmentationMoveOperation = enum(c_int) {
    copy = 0,
    ignore = 1,
    destroy = 2,
    _,
};

// Flags

pub const AllocatorCreateFlags = packed struct(u32) {
    externally_synchronized_bit: bool = false,
    khr_dedicated_allocation_bit: bool = false,
    khr_bind_memory2_bit: bool = false,
    ext_memory_budget_bit: bool = false,
    amd_device_coherent_memory_bit: bool = false,
    buffer_device_address_bit: bool = false,
    ext_memory_priority_bit: bool = false,
    khr_maintenance4_bit: bool = false,
    khr_maintenance5_bit: bool = false,
    khr_external_memory_win32_bit: bool = false,
    _reserved_bit_10: u1 = 0,
    _reserved_bit_11: u1 = 0,
    _reserved_bit_12: u1 = 0,
    _reserved_bit_13: u1 = 0,
    _reserved_bit_14: u1 = 0,
    _reserved_bit_15: u1 = 0,
    _reserved_bit_16: u1 = 0,
    _reserved_bit_17: u1 = 0,
    _reserved_bit_18: u1 = 0,
    _reserved_bit_19: u1 = 0,
    _reserved_bit_20: u1 = 0,
    _reserved_bit_21: u1 = 0,
    _reserved_bit_22: u1 = 0,
    _reserved_bit_23: u1 = 0,
    _reserved_bit_24: u1 = 0,
    _reserved_bit_25: u1 = 0,
    _reserved_bit_26: u1 = 0,
    _reserved_bit_27: u1 = 0,
    _reserved_bit_28: u1 = 0,
    _reserved_bit_29: u1 = 0,
    _reserved_bit_30: u1 = 0,
    _reserved_bit_31: u1 = 0,

    pub fn toInt(self: @This()) u32 {
        return @bitCast(self);
    }
    pub fn fromInt(flags: u32) @This() {
        return @bitCast(flags);
    }
};

pub const AllocationCreateFlags = packed struct(u32) {
    dedicated_memory_bit: bool = false, // bit 0
    never_allocate_bit: bool = false, // bit 1
    mapped_bit: bool = false, // bit 2
    _reserved_bit_3: u1 = 0,
    _reserved_bit_4: u1 = 0,
    user_data_copy_string_bit: bool = false, // bit 5 (deprecated)
    upper_address_bit: bool = false, // bit 6
    dont_bind_bit: bool = false, // bit 7
    within_budget_bit: bool = false, // bit 8
    can_alias_bit: bool = false, // bit 9
    host_access_sequential_write_bit: bool = false, // bit 10
    host_access_random_bit: bool = false, // bit 11
    host_access_allow_transfer_instead_bit: bool = false, // bit 12
    _reserved_bit_13: u1 = 0,
    _reserved_bit_14: u1 = 0,
    _reserved_bit_15: u1 = 0,
    strategy_min_memory_bit: bool = false, // bit 16
    strategy_min_time_bit: bool = false, // bit 17
    strategy_min_offset_bit: bool = false, // bit 18
    _reserved_bit_19: u1 = 0,
    _reserved_bit_20: u1 = 0,
    _reserved_bit_21: u1 = 0,
    _reserved_bit_22: u1 = 0,
    _reserved_bit_23: u1 = 0,
    _reserved_bit_24: u1 = 0,
    _reserved_bit_25: u1 = 0,
    _reserved_bit_26: u1 = 0,
    _reserved_bit_27: u1 = 0,
    _reserved_bit_28: u1 = 0,
    _reserved_bit_29: u1 = 0,
    _reserved_bit_30: u1 = 0,
    _reserved_bit_31: u1 = 0,

    pub fn toInt(self: @This()) u32 {
        return @bitCast(self);
    }
    pub fn fromInt(flags: u32) @This() {
        return @bitCast(flags);
    }
};

pub const PoolCreateFlags = packed struct(u32) {
    _reserved_bit_0: u1 = 0,
    ignore_buffer_image_granularity_bit: bool = false, // bit 1
    linear_algorithm_bit: bool = false, // bit 2
    _reserved_bit_3: u1 = 0,
    _reserved_bit_4: u1 = 0,
    _reserved_bit_5: u1 = 0,
    _reserved_bit_6: u1 = 0,
    _reserved_bit_7: u1 = 0,
    _reserved_bit_8: u1 = 0,
    _reserved_bit_9: u1 = 0,
    _reserved_bit_10: u1 = 0,
    _reserved_bit_11: u1 = 0,
    _reserved_bit_12: u1 = 0,
    _reserved_bit_13: u1 = 0,
    _reserved_bit_14: u1 = 0,
    _reserved_bit_15: u1 = 0,
    _reserved_bit_16: u1 = 0,
    _reserved_bit_17: u1 = 0,
    _reserved_bit_18: u1 = 0,
    _reserved_bit_19: u1 = 0,
    _reserved_bit_20: u1 = 0,
    _reserved_bit_21: u1 = 0,
    _reserved_bit_22: u1 = 0,
    _reserved_bit_23: u1 = 0,
    _reserved_bit_24: u1 = 0,
    _reserved_bit_25: u1 = 0,
    _reserved_bit_26: u1 = 0,
    _reserved_bit_27: u1 = 0,
    _reserved_bit_28: u1 = 0,
    _reserved_bit_29: u1 = 0,
    _reserved_bit_30: u1 = 0,
    _reserved_bit_31: u1 = 0,

    pub fn toInt(self: @This()) u32 {
        return @bitCast(self);
    }
    pub fn fromInt(flags: u32) @This() {
        return @bitCast(flags);
    }
};

pub const DefragmentationFlags = packed struct(u32) {
    algorithm_fast_bit: bool = false, // bit 0
    algorithm_balanced_bit: bool = false, // bit 1
    algorithm_full_bit: bool = false, // bit 2
    algorithm_extensive_bit: bool = false, // bit 3
    _reserved_bit_4: u1 = 0,
    _reserved_bit_5: u1 = 0,
    _reserved_bit_6: u1 = 0,
    _reserved_bit_7: u1 = 0,
    _reserved_bit_8: u1 = 0,
    _reserved_bit_9: u1 = 0,
    _reserved_bit_10: u1 = 0,
    _reserved_bit_11: u1 = 0,
    _reserved_bit_12: u1 = 0,
    _reserved_bit_13: u1 = 0,
    _reserved_bit_14: u1 = 0,
    _reserved_bit_15: u1 = 0,
    _reserved_bit_16: u1 = 0,
    _reserved_bit_17: u1 = 0,
    _reserved_bit_18: u1 = 0,
    _reserved_bit_19: u1 = 0,
    _reserved_bit_20: u1 = 0,
    _reserved_bit_21: u1 = 0,
    _reserved_bit_22: u1 = 0,
    _reserved_bit_23: u1 = 0,
    _reserved_bit_24: u1 = 0,
    _reserved_bit_25: u1 = 0,
    _reserved_bit_26: u1 = 0,
    _reserved_bit_27: u1 = 0,
    _reserved_bit_28: u1 = 0,
    _reserved_bit_29: u1 = 0,
    _reserved_bit_30: u1 = 0,
    _reserved_bit_31: u1 = 0,

    pub fn toInt(self: @This()) u32 {
        return @bitCast(self);
    }
    pub fn fromInt(flags: u32) @This() {
        return @bitCast(flags);
    }
};

pub const VirtualBlockCreateFlags = packed struct(u32) {
    linear_algorithm_bit: bool = false, // bit 0
    _reserved_bit_1: u1 = 0,
    _reserved_bit_2: u1 = 0,
    _reserved_bit_3: u1 = 0,
    _reserved_bit_4: u1 = 0,
    _reserved_bit_5: u1 = 0,
    _reserved_bit_6: u1 = 0,
    _reserved_bit_7: u1 = 0,
    _reserved_bit_8: u1 = 0,
    _reserved_bit_9: u1 = 0,
    _reserved_bit_10: u1 = 0,
    _reserved_bit_11: u1 = 0,
    _reserved_bit_12: u1 = 0,
    _reserved_bit_13: u1 = 0,
    _reserved_bit_14: u1 = 0,
    _reserved_bit_15: u1 = 0,
    _reserved_bit_16: u1 = 0,
    _reserved_bit_17: u1 = 0,
    _reserved_bit_18: u1 = 0,
    _reserved_bit_19: u1 = 0,
    _reserved_bit_20: u1 = 0,
    _reserved_bit_21: u1 = 0,
    _reserved_bit_22: u1 = 0,
    _reserved_bit_23: u1 = 0,
    _reserved_bit_24: u1 = 0,
    _reserved_bit_25: u1 = 0,
    _reserved_bit_26: u1 = 0,
    _reserved_bit_27: u1 = 0,
    _reserved_bit_28: u1 = 0,
    _reserved_bit_29: u1 = 0,
    _reserved_bit_30: u1 = 0,
    _reserved_bit_31: u1 = 0,

    pub fn toInt(self: @This()) u32 {
        return @bitCast(self);
    }
    pub fn fromInt(flags: u32) @This() {
        return @bitCast(flags);
    }
};

pub const VirtualAllocationCreateFlags = packed struct(u32) {
    _reserved_bit_0: u1 = 0,
    _reserved_bit_1: u1 = 0,
    _reserved_bit_2: u1 = 0,
    _reserved_bit_3: u1 = 0,
    _reserved_bit_4: u1 = 0,
    _reserved_bit_5: u1 = 0,
    upper_address_bit: bool = false, // bit 6
    _reserved_bit_7: u1 = 0,
    _reserved_bit_8: u1 = 0,
    _reserved_bit_9: u1 = 0,
    _reserved_bit_10: u1 = 0,
    _reserved_bit_11: u1 = 0,
    _reserved_bit_12: u1 = 0,
    _reserved_bit_13: u1 = 0,
    _reserved_bit_14: u1 = 0,
    _reserved_bit_15: u1 = 0,
    strategy_min_memory_bit: bool = false, // bit 16
    strategy_min_time_bit: bool = false, // bit 17
    strategy_min_offset_bit: bool = false, // bit 18
    _reserved_bit_19: u1 = 0,
    _reserved_bit_20: u1 = 0,
    _reserved_bit_21: u1 = 0,
    _reserved_bit_22: u1 = 0,
    _reserved_bit_23: u1 = 0,
    _reserved_bit_24: u1 = 0,
    _reserved_bit_25: u1 = 0,
    _reserved_bit_26: u1 = 0,
    _reserved_bit_27: u1 = 0,
    _reserved_bit_28: u1 = 0,
    _reserved_bit_29: u1 = 0,
    _reserved_bit_30: u1 = 0,
    _reserved_bit_31: u1 = 0,

    pub fn toInt(self: @This()) u32 {
        return @bitCast(self);
    }
    pub fn fromInt(flags: u32) @This() {
        return @bitCast(flags);
    }
};

// Opaque handle types (VMA-internal, kept as C aliases)

pub const Allocator = c.VmaAllocator;
pub const Allocation = c.VmaAllocation;
pub const Pool = c.VmaPool;
pub const DefragmentationContext = c.VmaDefragmentationContext;
pub const VirtualAllocation = c.VmaVirtualAllocation;
pub const VirtualBlock = c.VmaVirtualBlock;

// Callback function pointer types

pub const PfnAllocateDeviceMemory = *const fn (
    allocator: Allocator,
    memory_type: u32,
    memory: vk.DeviceMemory,
    size: vk.DeviceSize,
    p_user_data: ?*anyopaque,
) callconv(vk.vulkan_call_conv) void;

pub const PfnFreeDeviceMemory = *const fn (
    allocator: Allocator,
    memory_type: u32,
    memory: vk.DeviceMemory,
    size: vk.DeviceSize,
    p_user_data: ?*anyopaque,
) callconv(vk.vulkan_call_conv) void;

pub const PfnCheckDefragmentationBreak = *const fn (
    p_user_data: ?*anyopaque,
) callconv(vk.vulkan_call_conv) vk.Bool32;

// Structs

pub const DeviceMemoryCallbacks = extern struct {
    pfn_allocate: ?PfnAllocateDeviceMemory = null,
    pfn_free: ?PfnFreeDeviceMemory = null,
    p_user_data: ?*anyopaque = null,
};

pub const Statistics = extern struct {
    block_count: u32 = 0,
    allocation_count: u32 = 0,
    block_bytes: vk.DeviceSize = 0,
    allocation_bytes: vk.DeviceSize = 0,
};

pub const DetailedStatistics = extern struct {
    statistics: Statistics = .{},
    unused_range_count: u32 = 0,
    _pad0: u32 = 0,
    allocation_size_min: vk.DeviceSize = 0,
    allocation_size_max: vk.DeviceSize = 0,
    unused_range_size_min: vk.DeviceSize = 0,
    unused_range_size_max: vk.DeviceSize = 0,
};

pub const TotalStatistics = extern struct {
    memory_type: [c.VK_MAX_MEMORY_TYPES]DetailedStatistics = undefined,
    memory_heap: [c.VK_MAX_MEMORY_HEAPS]DetailedStatistics = undefined,
    total: DetailedStatistics = .{},
};

pub const Budget = extern struct {
    statistics: Statistics = .{},
    usage: vk.DeviceSize = 0,
    budget: vk.DeviceSize = 0,
};

pub const AllocationCreateInfo = extern struct {
    flags: AllocationCreateFlags = .{},
    usage: MemoryUsage = .auto,
    required_flags: vk.MemoryPropertyFlags = .{},
    preferred_flags: vk.MemoryPropertyFlags = .{},
    memory_type_bits: u32 = 0,
    _pad0: u32 = 0,
    pool: Pool = null,
    p_user_data: ?*anyopaque = null,
    priority: f32 = 0,
    _pad1: u32 = 0,
};

pub const AllocationInfo = extern struct {
    memory_type: u32 = 0,
    _pad0: u32 = 0,
    device_memory: vk.DeviceMemory = .null_handle,
    offset: vk.DeviceSize = 0,
    size: vk.DeviceSize = 0,
    p_mapped_data: ?*anyopaque = null,
    p_user_data: ?*anyopaque = null,
    p_name: ?[*:0]const u8 = null,
};

pub const AllocationInfo2 = extern struct {
    allocation_info: AllocationInfo = .{},
    block_size: vk.DeviceSize = 0,
    dedicated_memory: vk.Bool32 = .false,
    _pad0: u32 = 0,
};

pub const PoolCreateInfo = extern struct {
    memory_type_index: u32 = 0,
    flags: PoolCreateFlags = .{},
    block_size: vk.DeviceSize = 0,
    min_block_count: usize = 0,
    max_block_count: usize = 0,
    priority: f32 = 0,
    _pad0: u32 = 0,
    min_allocation_alignment: vk.DeviceSize = 0,
    p_memory_allocate_next: ?*anyopaque = null,
};

pub const AllocatorCreateInfo = extern struct {
    flags: AllocatorCreateFlags = .{},
    _pad0: u32 = 0,
    physical_device: vk.PhysicalDevice = .null_handle,
    device: vk.Device = .null_handle,
    preferred_large_heap_block_size: vk.DeviceSize = 0,
    p_allocation_callbacks: ?*const vk.AllocationCallbacks = null,
    p_device_memory_callbacks: ?*const DeviceMemoryCallbacks = null,
    p_heap_size_limit: ?[*]const vk.DeviceSize = null,
    p_vulkan_functions: ?*const VulkanFunctions = null,
    instance: vk.Instance = .null_handle,
    vulkan_api_version: u32 = 0,
    _pad1: u32 = 0,
    p_type_external_memory_handle_types: ?[*]const vk.ExternalMemoryHandleTypeFlagsKHR = null,
};

pub const AllocatorInfo = extern struct {
    instance: vk.Instance = .null_handle,
    physical_device: vk.PhysicalDevice = .null_handle,
    device: vk.Device = .null_handle,
};

pub const DefragmentationInfo = extern struct {
    flags: DefragmentationFlags = .{},
    _pad0: u32 = 0,
    pool: Pool = null,
    max_bytes_per_pass: vk.DeviceSize = 0,
    max_allocations_per_pass: u32 = 0,
    _pad1: u32 = 0,
    pfn_break_callback: ?PfnCheckDefragmentationBreak = null,
    p_break_callback_user_data: ?*anyopaque = null,
};

pub const DefragmentationMove = extern struct {
    operation: DefragmentationMoveOperation = .copy,
    _pad0: u32 = 0,
    src_allocation: Allocation = null,
    dst_tmp_allocation: Allocation = null,
};

pub const DefragmentationPassMoveInfo = extern struct {
    move_count: u32 = 0,
    _pad0: u32 = 0,
    p_moves: ?[*]DefragmentationMove = null,
};

pub const DefragmentationStats = extern struct {
    bytes_moved: vk.DeviceSize = 0,
    bytes_freed: vk.DeviceSize = 0,
    allocations_moved: u32 = 0,
    device_memory_blocks_freed: u32 = 0,
};

pub const VirtualBlockCreateInfo = extern struct {
    size: vk.DeviceSize = 0,
    flags: VirtualBlockCreateFlags = .{},
    _pad0: u32 = 0,
    p_allocation_callbacks: ?*const vk.AllocationCallbacks = null,
};

pub const VirtualAllocationCreateInfo = extern struct {
    size: vk.DeviceSize = 0,
    alignment: vk.DeviceSize = 0,
    flags: VirtualAllocationCreateFlags = .{},
    _pad0: u32 = 0,
    p_user_data: ?*anyopaque = null,
};

pub const VirtualAllocationInfo = extern struct {
    offset: vk.DeviceSize = 0,
    size: vk.DeviceSize = 0,
    p_user_data: ?*anyopaque = null,
};

// VulkanFunctions — matches C VmaVulkanFunctions layout for Vulkan 1.3+ on non-Windows.
// All fields are nullable function pointers with C calling convention.

pub const VulkanFunctions = extern struct {
    vkGetInstanceProcAddr: ?vk.PfnGetInstanceProcAddr = null,
    vkGetDeviceProcAddr: ?vk.PfnGetDeviceProcAddr = null,
    vkGetPhysicalDeviceProperties: ?vk.PfnGetPhysicalDeviceProperties = null,
    vkGetPhysicalDeviceMemoryProperties: ?vk.PfnGetPhysicalDeviceMemoryProperties = null,
    vkAllocateMemory: ?vk.PfnAllocateMemory = null,
    vkFreeMemory: ?vk.PfnFreeMemory = null,
    vkMapMemory: ?vk.PfnMapMemory = null,
    vkUnmapMemory: ?vk.PfnUnmapMemory = null,
    vkFlushMappedMemoryRanges: ?vk.PfnFlushMappedMemoryRanges = null,
    vkInvalidateMappedMemoryRanges: ?vk.PfnInvalidateMappedMemoryRanges = null,
    vkBindBufferMemory: ?vk.PfnBindBufferMemory = null,
    vkBindImageMemory: ?vk.PfnBindImageMemory = null,
    vkGetBufferMemoryRequirements: ?vk.PfnGetBufferMemoryRequirements = null,
    vkGetImageMemoryRequirements: ?vk.PfnGetImageMemoryRequirements = null,
    vkCreateBuffer: ?vk.PfnCreateBuffer = null,
    vkDestroyBuffer: ?vk.PfnDestroyBuffer = null,
    vkCreateImage: ?vk.PfnCreateImage = null,
    vkDestroyImage: ?vk.PfnDestroyImage = null,
    vkCmdCopyBuffer: ?vk.PfnCmdCopyBuffer = null,
    vkGetBufferMemoryRequirements2KHR: ?vk.PfnGetBufferMemoryRequirements2KHR = null,
    vkGetImageMemoryRequirements2KHR: ?vk.PfnGetImageMemoryRequirements2KHR = null,
    vkBindBufferMemory2KHR: ?vk.PfnBindBufferMemory2KHR = null,
    vkBindImageMemory2KHR: ?vk.PfnBindImageMemory2KHR = null,
    vkGetPhysicalDeviceMemoryProperties2KHR: ?vk.PfnGetPhysicalDeviceMemoryProperties2KHR = null,
    vkGetDeviceBufferMemoryRequirements: ?vk.PfnGetDeviceBufferMemoryRequirementsKHR = null,
    vkGetDeviceImageMemoryRequirements: ?vk.PfnGetDeviceImageMemoryRequirementsKHR = null,
    /// void* on non-Windows (VMA_EXTERNAL_MEMORY_WIN32 not set).
    vkGetMemoryWin32HandleKHR: ?*const anyopaque = null,
};

/// Build a `VulkanFunctions` struct from vulkan-zig dispatch tables.
/// Accepts the `.dispatch` field from any BaseWrapper, InstanceWrapper,
/// and DeviceWrapper (or compatible structs with matching field names).
pub fn vulkanFunctionsFromDispatch(
    base_dispatch: anytype,
    instance_dispatch: anytype,
    device_dispatch: anytype,
) VulkanFunctions {
    const BD = @TypeOf(base_dispatch);
    const ID = @TypeOf(instance_dispatch);
    const DD = @TypeOf(device_dispatch);

    return .{
        .vkGetInstanceProcAddr = if (@hasField(BD, "vkGetInstanceProcAddr")) base_dispatch.vkGetInstanceProcAddr else null,
        .vkGetDeviceProcAddr = if (@hasField(ID, "vkGetDeviceProcAddr")) instance_dispatch.vkGetDeviceProcAddr else null,
        .vkGetPhysicalDeviceProperties = if (@hasField(ID, "vkGetPhysicalDeviceProperties")) instance_dispatch.vkGetPhysicalDeviceProperties else null,
        .vkGetPhysicalDeviceMemoryProperties = if (@hasField(ID, "vkGetPhysicalDeviceMemoryProperties")) instance_dispatch.vkGetPhysicalDeviceMemoryProperties else null,
        .vkAllocateMemory = if (@hasField(DD, "vkAllocateMemory")) device_dispatch.vkAllocateMemory else null,
        .vkFreeMemory = if (@hasField(DD, "vkFreeMemory")) device_dispatch.vkFreeMemory else null,
        .vkMapMemory = if (@hasField(DD, "vkMapMemory")) device_dispatch.vkMapMemory else null,
        .vkUnmapMemory = if (@hasField(DD, "vkUnmapMemory")) device_dispatch.vkUnmapMemory else null,
        .vkFlushMappedMemoryRanges = if (@hasField(DD, "vkFlushMappedMemoryRanges")) device_dispatch.vkFlushMappedMemoryRanges else null,
        .vkInvalidateMappedMemoryRanges = if (@hasField(DD, "vkInvalidateMappedMemoryRanges")) device_dispatch.vkInvalidateMappedMemoryRanges else null,
        .vkBindBufferMemory = if (@hasField(DD, "vkBindBufferMemory")) device_dispatch.vkBindBufferMemory else null,
        .vkBindImageMemory = if (@hasField(DD, "vkBindImageMemory")) device_dispatch.vkBindImageMemory else null,
        .vkGetBufferMemoryRequirements = if (@hasField(DD, "vkGetBufferMemoryRequirements")) device_dispatch.vkGetBufferMemoryRequirements else null,
        .vkGetImageMemoryRequirements = if (@hasField(DD, "vkGetImageMemoryRequirements")) device_dispatch.vkGetImageMemoryRequirements else null,
        .vkCreateBuffer = if (@hasField(DD, "vkCreateBuffer")) device_dispatch.vkCreateBuffer else null,
        .vkDestroyBuffer = if (@hasField(DD, "vkDestroyBuffer")) device_dispatch.vkDestroyBuffer else null,
        .vkCreateImage = if (@hasField(DD, "vkCreateImage")) device_dispatch.vkCreateImage else null,
        .vkDestroyImage = if (@hasField(DD, "vkDestroyImage")) device_dispatch.vkDestroyImage else null,
        .vkCmdCopyBuffer = if (@hasField(DD, "vkCmdCopyBuffer")) device_dispatch.vkCmdCopyBuffer else null,
        .vkGetBufferMemoryRequirements2KHR = if (@hasField(DD, "vkGetBufferMemoryRequirements2KHR")) device_dispatch.vkGetBufferMemoryRequirements2KHR else null,
        .vkGetImageMemoryRequirements2KHR = if (@hasField(DD, "vkGetImageMemoryRequirements2KHR")) device_dispatch.vkGetImageMemoryRequirements2KHR else null,
        .vkBindBufferMemory2KHR = if (@hasField(DD, "vkBindBufferMemory2KHR")) device_dispatch.vkBindBufferMemory2KHR else null,
        .vkBindImageMemory2KHR = if (@hasField(DD, "vkBindImageMemory2KHR")) device_dispatch.vkBindImageMemory2KHR else null,
        .vkGetPhysicalDeviceMemoryProperties2KHR = if (@hasField(ID, "vkGetPhysicalDeviceMemoryProperties2KHR")) instance_dispatch.vkGetPhysicalDeviceMemoryProperties2KHR else null,
        .vkGetDeviceBufferMemoryRequirements = if (@hasField(DD, "vkGetDeviceBufferMemoryRequirements")) device_dispatch.vkGetDeviceBufferMemoryRequirements else null,
        .vkGetDeviceImageMemoryRequirements = if (@hasField(DD, "vkGetDeviceImageMemoryRequirements")) device_dispatch.vkGetDeviceImageMemoryRequirements else null,
    };
}

// Function wrappers — result-returning (Error!T)

pub inline fn createAllocator(create_info: AllocatorCreateInfo) Error!Allocator {
    var allocator: Allocator = undefined;
    try checkResult(c.vmaCreateAllocator(@ptrCast(&create_info), @ptrCast(&allocator)));
    return allocator;
}

pub inline fn findMemoryTypeIndex(allocator: Allocator, memory_type_bits: u32, alloc_create_info: AllocationCreateInfo) Error!u32 {
    var index: u32 = undefined;
    try checkResult(c.vmaFindMemoryTypeIndex(allocator, memory_type_bits, @ptrCast(&alloc_create_info), &index));
    return index;
}

pub inline fn findMemoryTypeIndexForBufferInfo(allocator: Allocator, buffer_create_info: vk.BufferCreateInfo, alloc_create_info: AllocationCreateInfo) Error!u32 {
    var index: u32 = undefined;
    try checkResult(c.vmaFindMemoryTypeIndexForBufferInfo(allocator, @ptrCast(&buffer_create_info), @ptrCast(&alloc_create_info), &index));
    return index;
}

pub inline fn findMemoryTypeIndexForImageInfo(allocator: Allocator, image_create_info: vk.ImageCreateInfo, alloc_create_info: AllocationCreateInfo) Error!u32 {
    var index: u32 = undefined;
    try checkResult(c.vmaFindMemoryTypeIndexForImageInfo(allocator, @ptrCast(&image_create_info), @ptrCast(&alloc_create_info), &index));
    return index;
}

pub inline fn createPool(allocator: Allocator, create_info: PoolCreateInfo) Error!Pool {
    var pool: Pool = undefined;
    try checkResult(c.vmaCreatePool(allocator, @ptrCast(&create_info), @ptrCast(&pool)));
    return pool;
}

pub inline fn checkPoolCorruption(allocator: Allocator, pool: Pool) Error!void {
    try checkResult(c.vmaCheckPoolCorruption(allocator, pool));
}

pub inline fn allocateMemory(allocator: Allocator, memory_requirements: vk.MemoryRequirements, create_info: AllocationCreateInfo) Error!struct { allocation: Allocation, allocation_info: AllocationInfo } {
    var allocation: Allocation = undefined;
    var info: AllocationInfo = undefined;
    try checkResult(c.vmaAllocateMemory(allocator, @ptrCast(&memory_requirements), @ptrCast(&create_info), @ptrCast(&allocation), @ptrCast(&info)));
    return .{ .allocation = allocation, .allocation_info = info };
}

pub inline fn allocateMemoryPages(allocator: Allocator, memory_requirements: vk.MemoryRequirements, create_info: AllocationCreateInfo, allocation_count: usize, allocations: [*]Allocation, allocation_infos: ?[*]AllocationInfo) Error!void {
    try checkResult(c.vmaAllocateMemoryPages(allocator, @ptrCast(&memory_requirements), @ptrCast(&create_info), allocation_count, @ptrCast(allocations), @ptrCast(allocation_infos)));
}

pub inline fn allocateMemoryForBuffer(allocator: Allocator, buffer: vk.Buffer, create_info: AllocationCreateInfo) Error!struct { allocation: Allocation, allocation_info: AllocationInfo } {
    var allocation: Allocation = undefined;
    var info: AllocationInfo = undefined;
    try checkResult(c.vmaAllocateMemoryForBuffer(allocator, @ptrFromInt(@intFromEnum(buffer)), @ptrCast(&create_info), @ptrCast(&allocation), @ptrCast(&info)));
    return .{ .allocation = allocation, .allocation_info = info };
}

pub inline fn allocateMemoryForImage(allocator: Allocator, image: vk.Image, create_info: AllocationCreateInfo) Error!struct { allocation: Allocation, allocation_info: AllocationInfo } {
    var allocation: Allocation = undefined;
    var info: AllocationInfo = undefined;
    try checkResult(c.vmaAllocateMemoryForImage(allocator, @ptrFromInt(@intFromEnum(image)), @ptrCast(&create_info), @ptrCast(&allocation), @ptrCast(&info)));
    return .{ .allocation = allocation, .allocation_info = info };
}

pub inline fn mapMemory(allocator: Allocator, allocation: Allocation) Error!?*anyopaque {
    var data: ?*anyopaque = null;
    try checkResult(c.vmaMapMemory(allocator, allocation, @ptrCast(&data)));
    return data;
}

pub inline fn flushAllocation(allocator: Allocator, allocation: Allocation, offset: vk.DeviceSize, size: vk.DeviceSize) Error!void {
    try checkResult(c.vmaFlushAllocation(allocator, allocation, offset, size));
}

pub inline fn invalidateAllocation(allocator: Allocator, allocation: Allocation, offset: vk.DeviceSize, size: vk.DeviceSize) Error!void {
    try checkResult(c.vmaInvalidateAllocation(allocator, allocation, offset, size));
}

pub inline fn flushAllocations(allocator: Allocator, allocation_count: u32, allocations: [*]const Allocation, offsets: ?[*]const vk.DeviceSize, sizes: ?[*]const vk.DeviceSize) Error!void {
    try checkResult(c.vmaFlushAllocations(allocator, allocation_count, @ptrCast(allocations), offsets, sizes));
}

pub inline fn invalidateAllocations(allocator: Allocator, allocation_count: u32, allocations: [*]const Allocation, offsets: ?[*]const vk.DeviceSize, sizes: ?[*]const vk.DeviceSize) Error!void {
    try checkResult(c.vmaInvalidateAllocations(allocator, allocation_count, @ptrCast(allocations), offsets, sizes));
}

pub inline fn copyMemoryToAllocation(allocator: Allocator, src: *const anyopaque, dst_allocation: Allocation, dst_offset: vk.DeviceSize, size: vk.DeviceSize) Error!void {
    try checkResult(c.vmaCopyMemoryToAllocation(allocator, src, dst_allocation, dst_offset, size));
}

pub inline fn copyAllocationToMemory(allocator: Allocator, src_allocation: Allocation, src_offset: vk.DeviceSize, dst: *anyopaque, size: vk.DeviceSize) Error!void {
    try checkResult(c.vmaCopyAllocationToMemory(allocator, src_allocation, src_offset, dst, size));
}

pub inline fn checkCorruption(allocator: Allocator, memory_type_bits: u32) Error!void {
    try checkResult(c.vmaCheckCorruption(allocator, memory_type_bits));
}

pub inline fn beginDefragmentation(allocator: Allocator, info: DefragmentationInfo) Error!DefragmentationContext {
    var ctx: DefragmentationContext = undefined;
    try checkResult(c.vmaBeginDefragmentation(allocator, @ptrCast(&info), @ptrCast(&ctx)));
    return ctx;
}

pub inline fn beginDefragmentationPass(allocator: Allocator, context: DefragmentationContext) Error!DefragmentationPassMoveInfo {
    var pass_info: DefragmentationPassMoveInfo = undefined;
    try checkResult(c.vmaBeginDefragmentationPass(allocator, context, @ptrCast(&pass_info)));
    return pass_info;
}

pub inline fn endDefragmentationPass(allocator: Allocator, context: DefragmentationContext, pass_info: *DefragmentationPassMoveInfo) Error!void {
    try checkResult(c.vmaEndDefragmentationPass(allocator, context, @ptrCast(pass_info)));
}

pub inline fn bindBufferMemory(allocator: Allocator, allocation: Allocation, buffer: vk.Buffer) Error!void {
    try checkResult(c.vmaBindBufferMemory(allocator, allocation, @ptrFromInt(@intFromEnum(buffer))));
}

pub inline fn bindBufferMemory2(allocator: Allocator, allocation: Allocation, allocation_local_offset: vk.DeviceSize, buffer: vk.Buffer, p_next: ?*const anyopaque) Error!void {
    try checkResult(c.vmaBindBufferMemory2(allocator, allocation, allocation_local_offset, @ptrFromInt(@intFromEnum(buffer)), p_next));
}

pub inline fn bindImageMemory(allocator: Allocator, allocation: Allocation, image: vk.Image) Error!void {
    try checkResult(c.vmaBindImageMemory(allocator, allocation, @ptrFromInt(@intFromEnum(image))));
}

pub inline fn bindImageMemory2(allocator: Allocator, allocation: Allocation, allocation_local_offset: vk.DeviceSize, image: vk.Image, p_next: ?*const anyopaque) Error!void {
    try checkResult(c.vmaBindImageMemory2(allocator, allocation, allocation_local_offset, @ptrFromInt(@intFromEnum(image)), p_next));
}

pub inline fn createBuffer(allocator: Allocator, buffer_create_info: vk.BufferCreateInfo, alloc_create_info: AllocationCreateInfo) Error!struct { buffer: vk.Buffer, allocation: Allocation, allocation_info: AllocationInfo } {
    var buffer: vk.Buffer = .null_handle;
    var allocation: Allocation = undefined;
    var info: AllocationInfo = undefined;
    try checkResult(c.vmaCreateBuffer(allocator, @ptrCast(&buffer_create_info), @ptrCast(&alloc_create_info), @ptrCast(&buffer), @ptrCast(&allocation), @ptrCast(&info)));
    return .{ .buffer = buffer, .allocation = allocation, .allocation_info = info };
}

pub inline fn createBufferWithAlignment(allocator: Allocator, buffer_create_info: vk.BufferCreateInfo, alloc_create_info: AllocationCreateInfo, min_alignment: vk.DeviceSize) Error!struct { buffer: vk.Buffer, allocation: Allocation, allocation_info: AllocationInfo } {
    var buffer: vk.Buffer = .null_handle;
    var allocation: Allocation = undefined;
    var info: AllocationInfo = undefined;
    try checkResult(c.vmaCreateBufferWithAlignment(allocator, @ptrCast(&buffer_create_info), @ptrCast(&alloc_create_info), min_alignment, @ptrCast(&buffer), @ptrCast(&allocation), @ptrCast(&info)));
    return .{ .buffer = buffer, .allocation = allocation, .allocation_info = info };
}

pub inline fn createAliasingBuffer(allocator: Allocator, allocation: Allocation, buffer_create_info: vk.BufferCreateInfo) Error!vk.Buffer {
    var buffer: vk.Buffer = .null_handle;
    try checkResult(c.vmaCreateAliasingBuffer(allocator, allocation, @ptrCast(&buffer_create_info), @ptrCast(&buffer)));
    return buffer;
}

pub inline fn createAliasingBuffer2(allocator: Allocator, allocation: Allocation, allocation_local_offset: vk.DeviceSize, buffer_create_info: vk.BufferCreateInfo) Error!vk.Buffer {
    var buffer: vk.Buffer = .null_handle;
    try checkResult(c.vmaCreateAliasingBuffer2(allocator, allocation, allocation_local_offset, @ptrCast(&buffer_create_info), @ptrCast(&buffer)));
    return buffer;
}

pub inline fn createImage(allocator: Allocator, image_create_info: vk.ImageCreateInfo, alloc_create_info: AllocationCreateInfo) Error!struct { image: vk.Image, allocation: Allocation, allocation_info: AllocationInfo } {
    var image: vk.Image = .null_handle;
    var allocation: Allocation = undefined;
    var info: AllocationInfo = undefined;
    try checkResult(c.vmaCreateImage(allocator, @ptrCast(&image_create_info), @ptrCast(&alloc_create_info), @ptrCast(&image), @ptrCast(&allocation), @ptrCast(&info)));
    return .{ .image = image, .allocation = allocation, .allocation_info = info };
}

pub inline fn createAliasingImage(allocator: Allocator, allocation: Allocation, image_create_info: vk.ImageCreateInfo) Error!vk.Image {
    var image: vk.Image = .null_handle;
    try checkResult(c.vmaCreateAliasingImage(allocator, allocation, @ptrCast(&image_create_info), @ptrCast(&image)));
    return image;
}

pub inline fn createAliasingImage2(allocator: Allocator, allocation: Allocation, allocation_local_offset: vk.DeviceSize, image_create_info: vk.ImageCreateInfo) Error!vk.Image {
    var image: vk.Image = .null_handle;
    try checkResult(c.vmaCreateAliasingImage2(allocator, allocation, allocation_local_offset, @ptrCast(&image_create_info), @ptrCast(&image)));
    return image;
}

pub inline fn createVirtualBlock(create_info: VirtualBlockCreateInfo) Error!VirtualBlock {
    var block: VirtualBlock = undefined;
    try checkResult(c.vmaCreateVirtualBlock(@ptrCast(&create_info), @ptrCast(&block)));
    return block;
}

pub inline fn virtualAllocate(block: VirtualBlock, create_info: VirtualAllocationCreateInfo) Error!struct { allocation: VirtualAllocation, offset: vk.DeviceSize } {
    var allocation: VirtualAllocation = undefined;
    var offset: vk.DeviceSize = 0;
    try checkResult(c.vmaVirtualAllocate(block, @ptrCast(&create_info), @ptrCast(&allocation), &offset));
    return .{ .allocation = allocation, .offset = offset };
}

// Function wrappers — non-result

pub inline fn destroyAllocator(allocator: Allocator) void {
    c.vmaDestroyAllocator(allocator);
}

pub inline fn getAllocatorInfo(allocator: Allocator) AllocatorInfo {
    var info: AllocatorInfo = undefined;
    c.vmaGetAllocatorInfo(allocator, @ptrCast(&info));
    return info;
}

pub inline fn getPhysicalDeviceProperties(allocator: Allocator) *const vk.PhysicalDeviceProperties {
    var props: *const vk.PhysicalDeviceProperties = undefined;
    c.vmaGetPhysicalDeviceProperties(allocator, @ptrCast(&props));
    return props;
}

pub inline fn getMemoryProperties(allocator: Allocator) *const vk.PhysicalDeviceMemoryProperties {
    var props: *const vk.PhysicalDeviceMemoryProperties = undefined;
    c.vmaGetMemoryProperties(allocator, @ptrCast(&props));
    return props;
}

pub inline fn getMemoryTypeProperties(allocator: Allocator, memory_type_index: u32) vk.MemoryPropertyFlags {
    var flags: vk.MemoryPropertyFlags = .{};
    c.vmaGetMemoryTypeProperties(allocator, memory_type_index, @ptrCast(&flags));
    return flags;
}

pub inline fn setCurrentFrameIndex(allocator: Allocator, frame_index: u32) void {
    c.vmaSetCurrentFrameIndex(allocator, frame_index);
}

pub inline fn calculateStatistics(allocator: Allocator) TotalStatistics {
    var stats: TotalStatistics = undefined;
    c.vmaCalculateStatistics(allocator, @ptrCast(&stats));
    return stats;
}

pub inline fn getHeapBudgets(allocator: Allocator, budgets: [*]Budget) void {
    c.vmaGetHeapBudgets(allocator, @ptrCast(budgets));
}

pub inline fn destroyPool(allocator: Allocator, pool: Pool) void {
    c.vmaDestroyPool(allocator, pool);
}

pub inline fn getPoolStatistics(allocator: Allocator, pool: Pool) Statistics {
    var stats: Statistics = undefined;
    c.vmaGetPoolStatistics(allocator, pool, @ptrCast(&stats));
    return stats;
}

pub inline fn calculatePoolStatistics(allocator: Allocator, pool: Pool) DetailedStatistics {
    var stats: DetailedStatistics = undefined;
    c.vmaCalculatePoolStatistics(allocator, pool, @ptrCast(&stats));
    return stats;
}

pub inline fn getPoolName(allocator: Allocator, pool: Pool) ?[*:0]const u8 {
    var name: ?[*:0]const u8 = null;
    c.vmaGetPoolName(allocator, pool, @ptrCast(&name));
    return name;
}

pub inline fn setPoolName(allocator: Allocator, pool: Pool, name: ?[*:0]const u8) void {
    c.vmaSetPoolName(allocator, pool, name);
}

pub inline fn freeMemory(allocator: Allocator, allocation: Allocation) void {
    c.vmaFreeMemory(allocator, allocation);
}

pub inline fn freeMemoryPages(allocator: Allocator, allocation_count: usize, allocations: [*]const Allocation) void {
    c.vmaFreeMemoryPages(allocator, allocation_count, @ptrCast(allocations));
}

pub inline fn getAllocationInfo(allocator: Allocator, allocation: Allocation) AllocationInfo {
    var info: AllocationInfo = undefined;
    c.vmaGetAllocationInfo(allocator, allocation, @ptrCast(&info));
    return info;
}

pub inline fn getAllocationInfo2(allocator: Allocator, allocation: Allocation) AllocationInfo2 {
    var info: AllocationInfo2 = undefined;
    c.vmaGetAllocationInfo2(allocator, allocation, @ptrCast(&info));
    return info;
}

pub inline fn setAllocationUserData(allocator: Allocator, allocation: Allocation, p_user_data: ?*anyopaque) void {
    c.vmaSetAllocationUserData(allocator, allocation, p_user_data);
}

pub inline fn setAllocationName(allocator: Allocator, allocation: Allocation, name: ?[*:0]const u8) void {
    c.vmaSetAllocationName(allocator, allocation, name);
}

pub inline fn getAllocationMemoryProperties(allocator: Allocator, allocation: Allocation) vk.MemoryPropertyFlags {
    var flags: vk.MemoryPropertyFlags = .{};
    c.vmaGetAllocationMemoryProperties(allocator, allocation, @ptrCast(&flags));
    return flags;
}

pub inline fn unmapMemory(allocator: Allocator, allocation: Allocation) void {
    c.vmaUnmapMemory(allocator, allocation);
}

pub inline fn endDefragmentation(allocator: Allocator, context: DefragmentationContext) DefragmentationStats {
    var stats: DefragmentationStats = undefined;
    c.vmaEndDefragmentation(allocator, context, @ptrCast(&stats));
    return stats;
}

pub inline fn destroyBuffer(allocator: Allocator, buffer: vk.Buffer, allocation: Allocation) void {
    c.vmaDestroyBuffer(allocator, @ptrFromInt(@intFromEnum(buffer)), allocation);
}

pub inline fn destroyImage(allocator: Allocator, image: vk.Image, allocation: Allocation) void {
    c.vmaDestroyImage(allocator, @ptrFromInt(@intFromEnum(image)), allocation);
}

pub inline fn destroyVirtualBlock(block: VirtualBlock) void {
    c.vmaDestroyVirtualBlock(block);
}

pub inline fn isVirtualBlockEmpty(block: VirtualBlock) bool {
    return c.vmaIsVirtualBlockEmpty(block) != 0;
}

pub inline fn getVirtualAllocationInfo(block: VirtualBlock, allocation: VirtualAllocation, info: *VirtualAllocationInfo) void {
    c.vmaGetVirtualAllocationInfo(block, allocation, @ptrCast(info));
}

pub inline fn virtualFree(block: VirtualBlock, allocation: VirtualAllocation) void {
    c.vmaVirtualFree(block, allocation);
}

pub inline fn clearVirtualBlock(block: VirtualBlock) void {
    c.vmaClearVirtualBlock(block);
}

pub inline fn setVirtualAllocationUserData(block: VirtualBlock, allocation: VirtualAllocation, p_user_data: ?*anyopaque) void {
    c.vmaSetVirtualAllocationUserData(block, allocation, p_user_data);
}

pub inline fn getVirtualBlockStatistics(block: VirtualBlock, stats: *Statistics) void {
    c.vmaGetVirtualBlockStatistics(block, @ptrCast(stats));
}

pub inline fn calculateVirtualBlockStatistics(block: VirtualBlock, stats: *DetailedStatistics) void {
    c.vmaCalculateVirtualBlockStatistics(block, @ptrCast(stats));
}

pub inline fn buildVirtualBlockStatsString(block: VirtualBlock, detailed_map: vk.Bool32) [*:0]u8 {
    var str: [*:0]u8 = undefined;
    c.vmaBuildVirtualBlockStatsString(block, @ptrCast(&str), detailed_map);
    return str;
}

pub inline fn freeVirtualBlockStatsString(block: VirtualBlock, stats_string: [*:0]u8) void {
    c.vmaFreeVirtualBlockStatsString(block, stats_string);
}

pub inline fn buildStatsString(allocator: Allocator, detailed_map: vk.Bool32) [*:0]u8 {
    var str: [*:0]u8 = undefined;
    c.vmaBuildStatsString(allocator, @ptrCast(&str), detailed_map);
    return str;
}

pub inline fn freeStatsString(allocator: Allocator, stats_string: [*:0]u8) void {
    c.vmaFreeStatsString(allocator, stats_string);
}

// Comptime layout assertions — verify our extern structs match the C layout.

comptime {
    assertLayoutMatch(AllocatorCreateInfo, c.VmaAllocatorCreateInfo);
    assertLayoutMatch(AllocatorInfo, c.VmaAllocatorInfo);
    assertLayoutMatch(AllocationCreateInfo, c.VmaAllocationCreateInfo);
    assertLayoutMatch(AllocationInfo, c.VmaAllocationInfo);
    assertLayoutMatch(AllocationInfo2, c.VmaAllocationInfo2);
    assertLayoutMatch(PoolCreateInfo, c.VmaPoolCreateInfo);
    assertLayoutMatch(Statistics, c.VmaStatistics);
    assertLayoutMatch(DetailedStatistics, c.VmaDetailedStatistics);
    assertLayoutMatch(TotalStatistics, c.VmaTotalStatistics);
    assertLayoutMatch(Budget, c.VmaBudget);
    assertLayoutMatch(DefragmentationInfo, c.VmaDefragmentationInfo);
    assertLayoutMatch(DefragmentationMove, c.VmaDefragmentationMove);
    assertLayoutMatch(DefragmentationPassMoveInfo, c.VmaDefragmentationPassMoveInfo);
    assertLayoutMatch(DefragmentationStats, c.VmaDefragmentationStats);
    assertLayoutMatch(VirtualBlockCreateInfo, c.VmaVirtualBlockCreateInfo);
    assertLayoutMatch(VirtualAllocationCreateInfo, c.VmaVirtualAllocationCreateInfo);
    assertLayoutMatch(VirtualAllocationInfo, c.VmaVirtualAllocationInfo);
    assertLayoutMatch(DeviceMemoryCallbacks, c.VmaDeviceMemoryCallbacks);
    assertLayoutMatch(VulkanFunctions, c.VmaVulkanFunctions);
}

fn assertLayoutMatch(comptime ZigT: type, comptime CT: type) void {
    if (@sizeOf(ZigT) != @sizeOf(CT)) {
        @compileError(std.fmt.comptimePrint(
            "{s} size mismatch: Zig={d} C={d}",
            .{ @typeName(ZigT), @sizeOf(ZigT), @sizeOf(CT) },
        ));
    }
    if (@alignOf(ZigT) != @alignOf(CT)) {
        @compileError(std.fmt.comptimePrint(
            "{s} alignment mismatch: Zig={d} C={d}",
            .{ @typeName(ZigT), @alignOf(ZigT), @alignOf(CT) },
        ));
    }
}
