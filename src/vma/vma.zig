// Zig bindings for VMA (Vulkan Memory Allocator).
//
// This module re-exports the VMA C API via @cImport and provides helper
// functions for bridging vulkan-zig types (handles as enums) with VMA's
// opaque pointer types.
//
// VMA is compiled with VMA_STATIC_VULKAN_FUNCTIONS=0 and
// VMA_DYNAMIC_VULKAN_FUNCTIONS=0, so the consumer must provide all Vulkan
// function pointers explicitly via VmaVulkanFunctions at allocator creation
// time.

const std = @import("std");
const vk = @import("vulkan");

pub const c = @cImport({
    @cDefine("VMA_STATIC_VULKAN_FUNCTIONS", "0");
    @cDefine("VMA_DYNAMIC_VULKAN_FUNCTIONS", "0");
    @cInclude("vk_mem_alloc.h");
});

/// Convert a VMA/Vulkan C result to the vulkan-zig Result enum.
inline fn toResult(result: c.VkResult) vk.Result {
    return @enumFromInt(result);
}

// ── Opaque handle types ─────────────────────────────────────────────────

pub const Allocator = c.VmaAllocator;
pub const Allocation = c.VmaAllocation;
pub const Pool = c.VmaPool;
pub const DefragmentationContext = c.VmaDefragmentationContext;
pub const VirtualAllocation = c.VmaVirtualAllocation;
pub const VirtualBlock = c.VmaVirtualBlock;

// ── Struct types ────────────────────────────────────────────────────────

pub const AllocatorCreateInfo = c.VmaAllocatorCreateInfo;
pub const AllocatorInfo = c.VmaAllocatorInfo;
pub const VulkanFunctions = c.VmaVulkanFunctions;
pub const DeviceMemoryCallbacks = c.VmaDeviceMemoryCallbacks;
pub const AllocationCreateInfo = c.VmaAllocationCreateInfo;
pub const AllocationInfo = c.VmaAllocationInfo;
pub const AllocationInfo2 = c.VmaAllocationInfo2;
pub const PoolCreateInfo = c.VmaPoolCreateInfo;
pub const Statistics = c.VmaStatistics;
pub const DetailedStatistics = c.VmaDetailedStatistics;
pub const TotalStatistics = c.VmaTotalStatistics;
pub const Budget = c.VmaBudget;
pub const DefragmentationInfo = c.VmaDefragmentationInfo;
pub const DefragmentationMove = c.VmaDefragmentationMove;
pub const DefragmentationPassMoveInfo = c.VmaDefragmentationPassMoveInfo;
pub const DefragmentationStats = c.VmaDefragmentationStats;
pub const VirtualBlockCreateInfo = c.VmaVirtualBlockCreateInfo;
pub const VirtualAllocationCreateInfo = c.VmaVirtualAllocationCreateInfo;
pub const VirtualAllocationInfo = c.VmaVirtualAllocationInfo;

// ── Flag / enum types ───────────────────────────────────────────────────

pub const AllocatorCreateFlagBits = c.VmaAllocatorCreateFlagBits;
pub const AllocatorCreateFlags = c.VmaAllocatorCreateFlags;
pub const MemoryUsage = c.VmaMemoryUsage;
pub const AllocationCreateFlagBits = c.VmaAllocationCreateFlagBits;
pub const AllocationCreateFlags = c.VmaAllocationCreateFlags;
pub const PoolCreateFlagBits = c.VmaPoolCreateFlagBits;
pub const PoolCreateFlags = c.VmaPoolCreateFlags;
pub const DefragmentationFlagBits = c.VmaDefragmentationFlagBits;
pub const DefragmentationFlags = c.VmaDefragmentationFlags;
pub const DefragmentationMoveOperation = c.VmaDefragmentationMoveOperation;
pub const VirtualBlockCreateFlagBits = c.VmaVirtualBlockCreateFlagBits;
pub const VirtualBlockCreateFlags = c.VmaVirtualBlockCreateFlags;
pub const VirtualAllocationCreateFlagBits = c.VmaVirtualAllocationCreateFlagBits;
pub const VirtualAllocationCreateFlags = c.VmaVirtualAllocationCreateFlags;

// ── Constants ───────────────────────────────────────────────────────────

pub const ALLOCATOR_CREATE_EXTERNALLY_SYNCHRONIZED_BIT = c.VMA_ALLOCATOR_CREATE_EXTERNALLY_SYNCHRONIZED_BIT;
pub const ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT = c.VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT;
pub const ALLOCATOR_CREATE_KHR_BIND_MEMORY2_BIT = c.VMA_ALLOCATOR_CREATE_KHR_BIND_MEMORY2_BIT;
pub const ALLOCATOR_CREATE_EXT_MEMORY_BUDGET_BIT = c.VMA_ALLOCATOR_CREATE_EXT_MEMORY_BUDGET_BIT;
pub const ALLOCATOR_CREATE_AMD_DEVICE_COHERENT_MEMORY_BIT = c.VMA_ALLOCATOR_CREATE_AMD_DEVICE_COHERENT_MEMORY_BIT;
pub const ALLOCATOR_CREATE_BUFFER_DEVICE_ADDRESS_BIT = c.VMA_ALLOCATOR_CREATE_BUFFER_DEVICE_ADDRESS_BIT;
pub const ALLOCATOR_CREATE_EXT_MEMORY_PRIORITY_BIT = c.VMA_ALLOCATOR_CREATE_EXT_MEMORY_PRIORITY_BIT;
pub const ALLOCATOR_CREATE_KHR_MAINTENANCE4_BIT = c.VMA_ALLOCATOR_CREATE_KHR_MAINTENANCE4_BIT;
pub const ALLOCATOR_CREATE_KHR_MAINTENANCE5_BIT = c.VMA_ALLOCATOR_CREATE_KHR_MAINTENANCE5_BIT;

pub const MEMORY_USAGE_UNKNOWN = c.VMA_MEMORY_USAGE_UNKNOWN;
pub const MEMORY_USAGE_GPU_ONLY = c.VMA_MEMORY_USAGE_GPU_ONLY;
pub const MEMORY_USAGE_CPU_ONLY = c.VMA_MEMORY_USAGE_CPU_ONLY;
pub const MEMORY_USAGE_CPU_TO_GPU = c.VMA_MEMORY_USAGE_CPU_TO_GPU;
pub const MEMORY_USAGE_GPU_TO_CPU = c.VMA_MEMORY_USAGE_GPU_TO_CPU;
pub const MEMORY_USAGE_CPU_COPY = c.VMA_MEMORY_USAGE_CPU_COPY;
pub const MEMORY_USAGE_GPU_LAZILY_ALLOCATED = c.VMA_MEMORY_USAGE_GPU_LAZILY_ALLOCATED;
pub const MEMORY_USAGE_AUTO = c.VMA_MEMORY_USAGE_AUTO;
pub const MEMORY_USAGE_AUTO_PREFER_DEVICE = c.VMA_MEMORY_USAGE_AUTO_PREFER_DEVICE;
pub const MEMORY_USAGE_AUTO_PREFER_HOST = c.VMA_MEMORY_USAGE_AUTO_PREFER_HOST;

pub const ALLOCATION_CREATE_DEDICATED_MEMORY_BIT = c.VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT;
pub const ALLOCATION_CREATE_NEVER_ALLOCATE_BIT = c.VMA_ALLOCATION_CREATE_NEVER_ALLOCATE_BIT;
pub const ALLOCATION_CREATE_MAPPED_BIT = c.VMA_ALLOCATION_CREATE_MAPPED_BIT;
pub const ALLOCATION_CREATE_UPPER_ADDRESS_BIT = c.VMA_ALLOCATION_CREATE_UPPER_ADDRESS_BIT;
pub const ALLOCATION_CREATE_DONT_BIND_BIT = c.VMA_ALLOCATION_CREATE_DONT_BIND_BIT;
pub const ALLOCATION_CREATE_WITHIN_BUDGET_BIT = c.VMA_ALLOCATION_CREATE_WITHIN_BUDGET_BIT;
pub const ALLOCATION_CREATE_CAN_ALIAS_BIT = c.VMA_ALLOCATION_CREATE_CAN_ALIAS_BIT;
pub const ALLOCATION_CREATE_HOST_ACCESS_SEQUENTIAL_WRITE_BIT = c.VMA_ALLOCATION_CREATE_HOST_ACCESS_SEQUENTIAL_WRITE_BIT;
pub const ALLOCATION_CREATE_HOST_ACCESS_RANDOM_BIT = c.VMA_ALLOCATION_CREATE_HOST_ACCESS_RANDOM_BIT;
pub const ALLOCATION_CREATE_HOST_ACCESS_ALLOW_TRANSFER_INSTEAD_BIT = c.VMA_ALLOCATION_CREATE_HOST_ACCESS_ALLOW_TRANSFER_INSTEAD_BIT;
pub const ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT = c.VMA_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT;
pub const ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT = c.VMA_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT;
pub const ALLOCATION_CREATE_STRATEGY_MIN_OFFSET_BIT = c.VMA_ALLOCATION_CREATE_STRATEGY_MIN_OFFSET_BIT;

// ── VMA function wrappers (VkResult → vk.Result) ───────────────────────

pub inline fn createAllocator(create_info: *const AllocatorCreateInfo, allocator: *Allocator) vk.Result {
    return toResult(c.vmaCreateAllocator(create_info, allocator));
}

pub inline fn findMemoryTypeIndex(allocator: Allocator, memory_type_bits: u32, alloc_create_info: *const AllocationCreateInfo, memory_type_index: *u32) vk.Result {
    return toResult(c.vmaFindMemoryTypeIndex(allocator, memory_type_bits, alloc_create_info, memory_type_index));
}

pub inline fn findMemoryTypeIndexForBufferInfo(allocator: Allocator, buffer_create_info: *const c.VkBufferCreateInfo, alloc_create_info: *const AllocationCreateInfo, memory_type_index: *u32) vk.Result {
    return toResult(c.vmaFindMemoryTypeIndexForBufferInfo(allocator, buffer_create_info, alloc_create_info, memory_type_index));
}

pub inline fn findMemoryTypeIndexForImageInfo(allocator: Allocator, image_create_info: *const c.VkImageCreateInfo, alloc_create_info: *const AllocationCreateInfo, memory_type_index: *u32) vk.Result {
    return toResult(c.vmaFindMemoryTypeIndexForImageInfo(allocator, image_create_info, alloc_create_info, memory_type_index));
}

pub inline fn createPool(allocator: Allocator, create_info: *const PoolCreateInfo, pool: *Pool) vk.Result {
    return toResult(c.vmaCreatePool(allocator, create_info, pool));
}

pub inline fn checkPoolCorruption(allocator: Allocator, pool: Pool) vk.Result {
    return toResult(c.vmaCheckPoolCorruption(allocator, pool));
}

pub inline fn allocateMemory(allocator: Allocator, memory_requirements: *const c.VkMemoryRequirements, create_info: *const AllocationCreateInfo, allocation: *Allocation, allocation_info: ?*AllocationInfo) vk.Result {
    return toResult(c.vmaAllocateMemory(allocator, memory_requirements, create_info, allocation, allocation_info));
}

pub inline fn allocateDedicatedMemory(allocator: Allocator, memory_requirements: *const c.VkMemoryRequirements, create_info: *const AllocationCreateInfo, memory_allocate_next: ?*anyopaque, allocation: *Allocation, allocation_info: ?*AllocationInfo) vk.Result {
    return toResult(c.vmaAllocateDedicatedMemory(allocator, memory_requirements, create_info, memory_allocate_next, allocation, allocation_info));
}

pub inline fn allocateMemoryPages(allocator: Allocator, memory_requirements: *const c.VkMemoryRequirements, create_info: *const AllocationCreateInfo, allocation_count: usize, allocations: *Allocation, allocation_info: ?*AllocationInfo) vk.Result {
    return toResult(c.vmaAllocateMemoryPages(allocator, memory_requirements, create_info, allocation_count, allocations, allocation_info));
}

pub inline fn allocateMemoryForBuffer(allocator: Allocator, buffer: c.VkBuffer, create_info: *const AllocationCreateInfo, allocation: *Allocation, allocation_info: ?*AllocationInfo) vk.Result {
    return toResult(c.vmaAllocateMemoryForBuffer(allocator, buffer, create_info, allocation, allocation_info));
}

pub inline fn allocateMemoryForImage(allocator: Allocator, image: c.VkImage, create_info: *const AllocationCreateInfo, allocation: *Allocation, allocation_info: ?*AllocationInfo) vk.Result {
    return toResult(c.vmaAllocateMemoryForImage(allocator, image, create_info, allocation, allocation_info));
}

pub inline fn mapMemory(allocator: Allocator, allocation: Allocation, pp_data: *?*anyopaque) vk.Result {
    return toResult(c.vmaMapMemory(allocator, allocation, pp_data));
}

pub inline fn flushAllocation(allocator: Allocator, allocation: Allocation, offset: c.VkDeviceSize, size: c.VkDeviceSize) vk.Result {
    return toResult(c.vmaFlushAllocation(allocator, allocation, offset, size));
}

pub inline fn invalidateAllocation(allocator: Allocator, allocation: Allocation, offset: c.VkDeviceSize, size: c.VkDeviceSize) vk.Result {
    return toResult(c.vmaInvalidateAllocation(allocator, allocation, offset, size));
}

pub inline fn flushAllocations(allocator: Allocator, allocation_count: u32, allocations: ?[*]const Allocation, offsets: ?[*]const c.VkDeviceSize, sizes: ?[*]const c.VkDeviceSize) vk.Result {
    return toResult(c.vmaFlushAllocations(allocator, allocation_count, allocations, offsets, sizes));
}

pub inline fn invalidateAllocations(allocator: Allocator, allocation_count: u32, allocations: ?[*]const Allocation, offsets: ?[*]const c.VkDeviceSize, sizes: ?[*]const c.VkDeviceSize) vk.Result {
    return toResult(c.vmaInvalidateAllocations(allocator, allocation_count, allocations, offsets, sizes));
}

pub inline fn copyMemoryToAllocation(allocator: Allocator, src_host_pointer: *const anyopaque, dst_allocation: Allocation, dst_allocation_local_offset: c.VkDeviceSize, size: c.VkDeviceSize) vk.Result {
    return toResult(c.vmaCopyMemoryToAllocation(allocator, src_host_pointer, dst_allocation, dst_allocation_local_offset, size));
}

pub inline fn copyAllocationToMemory(allocator: Allocator, src_allocation: Allocation, src_allocation_local_offset: c.VkDeviceSize, dst_host_pointer: *anyopaque, size: c.VkDeviceSize) vk.Result {
    return toResult(c.vmaCopyAllocationToMemory(allocator, src_allocation, src_allocation_local_offset, dst_host_pointer, size));
}

pub inline fn checkCorruption(allocator: Allocator, memory_type_bits: u32) vk.Result {
    return toResult(c.vmaCheckCorruption(allocator, memory_type_bits));
}

pub inline fn beginDefragmentation(allocator: Allocator, info: *const DefragmentationInfo, context: *DefragmentationContext) vk.Result {
    return toResult(c.vmaBeginDefragmentation(allocator, info, context));
}

pub inline fn beginDefragmentationPass(allocator: Allocator, context: DefragmentationContext, pass_info: *DefragmentationPassMoveInfo) vk.Result {
    return toResult(c.vmaBeginDefragmentationPass(allocator, context, pass_info));
}

pub inline fn endDefragmentationPass(allocator: Allocator, context: DefragmentationContext, pass_info: *DefragmentationPassMoveInfo) vk.Result {
    return toResult(c.vmaEndDefragmentationPass(allocator, context, pass_info));
}

pub inline fn bindBufferMemory(allocator: Allocator, allocation: Allocation, buffer: c.VkBuffer) vk.Result {
    return toResult(c.vmaBindBufferMemory(allocator, allocation, buffer));
}

pub inline fn bindBufferMemory2(allocator: Allocator, allocation: Allocation, allocation_local_offset: c.VkDeviceSize, buffer: c.VkBuffer, p_next: ?*const anyopaque) vk.Result {
    return toResult(c.vmaBindBufferMemory2(allocator, allocation, allocation_local_offset, buffer, p_next));
}

pub inline fn bindImageMemory(allocator: Allocator, allocation: Allocation, image: c.VkImage) vk.Result {
    return toResult(c.vmaBindImageMemory(allocator, allocation, image));
}

pub inline fn bindImageMemory2(allocator: Allocator, allocation: Allocation, allocation_local_offset: c.VkDeviceSize, image: c.VkImage, p_next: ?*const anyopaque) vk.Result {
    return toResult(c.vmaBindImageMemory2(allocator, allocation, allocation_local_offset, image, p_next));
}

pub inline fn createBuffer(allocator: Allocator, buffer_create_info: *const c.VkBufferCreateInfo, alloc_create_info: *const AllocationCreateInfo, buffer: *c.VkBuffer, allocation: *Allocation, allocation_info: ?*AllocationInfo) vk.Result {
    return toResult(c.vmaCreateBuffer(allocator, buffer_create_info, alloc_create_info, buffer, allocation, allocation_info));
}

pub inline fn createBufferWithAlignment(allocator: Allocator, buffer_create_info: *const c.VkBufferCreateInfo, alloc_create_info: *const AllocationCreateInfo, min_alignment: c.VkDeviceSize, buffer: *c.VkBuffer, allocation: *Allocation, allocation_info: ?*AllocationInfo) vk.Result {
    return toResult(c.vmaCreateBufferWithAlignment(allocator, buffer_create_info, alloc_create_info, min_alignment, buffer, allocation, allocation_info));
}

pub inline fn createAliasingBuffer(allocator: Allocator, allocation: Allocation, buffer_create_info: *const c.VkBufferCreateInfo, buffer: *c.VkBuffer) vk.Result {
    return toResult(c.vmaCreateAliasingBuffer(allocator, allocation, buffer_create_info, buffer));
}

pub inline fn createAliasingBuffer2(allocator: Allocator, allocation: Allocation, allocation_local_offset: c.VkDeviceSize, buffer_create_info: *const c.VkBufferCreateInfo, buffer: *c.VkBuffer) vk.Result {
    return toResult(c.vmaCreateAliasingBuffer2(allocator, allocation, allocation_local_offset, buffer_create_info, buffer));
}

pub inline fn createImage(allocator: Allocator, image_create_info: *const c.VkImageCreateInfo, alloc_create_info: *const AllocationCreateInfo, image: *c.VkImage, allocation: *Allocation, allocation_info: ?*AllocationInfo) vk.Result {
    return toResult(c.vmaCreateImage(allocator, image_create_info, alloc_create_info, image, allocation, allocation_info));
}

pub inline fn createAliasingImage(allocator: Allocator, allocation: Allocation, image_create_info: *const c.VkImageCreateInfo, image: *c.VkImage) vk.Result {
    return toResult(c.vmaCreateAliasingImage(allocator, allocation, image_create_info, image));
}

pub inline fn createAliasingImage2(allocator: Allocator, allocation: Allocation, allocation_local_offset: c.VkDeviceSize, image_create_info: *const c.VkImageCreateInfo, image: *c.VkImage) vk.Result {
    return toResult(c.vmaCreateAliasingImage2(allocator, allocation, allocation_local_offset, image_create_info, image));
}

pub inline fn createVirtualBlock(create_info: *const VirtualBlockCreateInfo, virtual_block: *VirtualBlock) vk.Result {
    return toResult(c.vmaCreateVirtualBlock(create_info, virtual_block));
}

pub inline fn virtualAllocate(virtual_block: VirtualBlock, create_info: *const VirtualAllocationCreateInfo, allocation: *VirtualAllocation, offset: ?*c.VkDeviceSize) vk.Result {
    return toResult(c.vmaVirtualAllocate(virtual_block, create_info, allocation, offset));
}

// ── VMA function re-exports (non-VkResult) ──────────────────────────────

pub const destroyAllocator = c.vmaDestroyAllocator;
pub const getAllocatorInfo = c.vmaGetAllocatorInfo;
pub const getPhysicalDeviceProperties = c.vmaGetPhysicalDeviceProperties;
pub const getMemoryProperties = c.vmaGetMemoryProperties;
pub const getMemoryTypeProperties = c.vmaGetMemoryTypeProperties;
pub const setCurrentFrameIndex = c.vmaSetCurrentFrameIndex;
pub const calculateStatistics = c.vmaCalculateStatistics;
pub const getHeapBudgets = c.vmaGetHeapBudgets;
pub const destroyPool = c.vmaDestroyPool;
pub const getPoolStatistics = c.vmaGetPoolStatistics;
pub const calculatePoolStatistics = c.vmaCalculatePoolStatistics;
pub const getPoolName = c.vmaGetPoolName;
pub const setPoolName = c.vmaSetPoolName;
pub const freeMemory = c.vmaFreeMemory;
pub const freeMemoryPages = c.vmaFreeMemoryPages;
pub const getAllocationInfo = c.vmaGetAllocationInfo;
pub const getAllocationInfo2 = c.vmaGetAllocationInfo2;
pub const setAllocationUserData = c.vmaSetAllocationUserData;
pub const setAllocationName = c.vmaSetAllocationName;
pub const getAllocationMemoryProperties = c.vmaGetAllocationMemoryProperties;
pub const unmapMemory = c.vmaUnmapMemory;
pub const endDefragmentation = c.vmaEndDefragmentation;
pub const destroyBuffer = c.vmaDestroyBuffer;
pub const destroyImage = c.vmaDestroyImage;
pub const destroyVirtualBlock = c.vmaDestroyVirtualBlock;
pub const isVirtualBlockEmpty = c.vmaIsVirtualBlockEmpty;
pub const getVirtualAllocationInfo = c.vmaGetVirtualAllocationInfo;
pub const virtualFree = c.vmaVirtualFree;
pub const clearVirtualBlock = c.vmaClearVirtualBlock;
pub const setVirtualAllocationUserData = c.vmaSetVirtualAllocationUserData;
pub const getVirtualBlockStatistics = c.vmaGetVirtualBlockStatistics;
pub const calculateVirtualBlockStatistics = c.vmaCalculateVirtualBlockStatistics;
pub const buildVirtualBlockStatsString = c.vmaBuildVirtualBlockStatsString;
pub const freeVirtualBlockStatsString = c.vmaFreeVirtualBlockStatsString;
pub const buildStatsString = c.vmaBuildStatsString;
pub const freeStatsString = c.vmaFreeStatsString;
