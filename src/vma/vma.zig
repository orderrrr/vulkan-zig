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

pub const c = @cImport({
    @cDefine("VMA_STATIC_VULKAN_FUNCTIONS", "0");
    @cDefine("VMA_DYNAMIC_VULKAN_FUNCTIONS", "0");
    @cInclude("vk_mem_alloc.h");
});

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

// ── VMA function re-exports ─────────────────────────────────────────────

pub const createAllocator = c.vmaCreateAllocator;
pub const destroyAllocator = c.vmaDestroyAllocator;
pub const getAllocatorInfo = c.vmaGetAllocatorInfo;
pub const getPhysicalDeviceProperties = c.vmaGetPhysicalDeviceProperties;
pub const getMemoryProperties = c.vmaGetMemoryProperties;
pub const getMemoryTypeProperties = c.vmaGetMemoryTypeProperties;
pub const setCurrentFrameIndex = c.vmaSetCurrentFrameIndex;
pub const calculateStatistics = c.vmaCalculateStatistics;
pub const getHeapBudgets = c.vmaGetHeapBudgets;
pub const findMemoryTypeIndex = c.vmaFindMemoryTypeIndex;
pub const findMemoryTypeIndexForBufferInfo = c.vmaFindMemoryTypeIndexForBufferInfo;
pub const findMemoryTypeIndexForImageInfo = c.vmaFindMemoryTypeIndexForImageInfo;
pub const createPool = c.vmaCreatePool;
pub const destroyPool = c.vmaDestroyPool;
pub const getPoolStatistics = c.vmaGetPoolStatistics;
pub const calculatePoolStatistics = c.vmaCalculatePoolStatistics;
pub const checkPoolCorruption = c.vmaCheckPoolCorruption;
pub const getPoolName = c.vmaGetPoolName;
pub const setPoolName = c.vmaSetPoolName;
pub const allocateMemory = c.vmaAllocateMemory;
pub const allocateDedicatedMemory = c.vmaAllocateDedicatedMemory;
pub const allocateMemoryPages = c.vmaAllocateMemoryPages;
pub const allocateMemoryForBuffer = c.vmaAllocateMemoryForBuffer;
pub const allocateMemoryForImage = c.vmaAllocateMemoryForImage;
pub const freeMemory = c.vmaFreeMemory;
pub const freeMemoryPages = c.vmaFreeMemoryPages;
pub const getAllocationInfo = c.vmaGetAllocationInfo;
pub const getAllocationInfo2 = c.vmaGetAllocationInfo2;
pub const setAllocationUserData = c.vmaSetAllocationUserData;
pub const setAllocationName = c.vmaSetAllocationName;
pub const getAllocationMemoryProperties = c.vmaGetAllocationMemoryProperties;
pub const mapMemory = c.vmaMapMemory;
pub const unmapMemory = c.vmaUnmapMemory;
pub const flushAllocation = c.vmaFlushAllocation;
pub const invalidateAllocation = c.vmaInvalidateAllocation;
pub const flushAllocations = c.vmaFlushAllocations;
pub const invalidateAllocations = c.vmaInvalidateAllocations;
pub const copyMemoryToAllocation = c.vmaCopyMemoryToAllocation;
pub const copyAllocationToMemory = c.vmaCopyAllocationToMemory;
pub const checkCorruption = c.vmaCheckCorruption;
pub const beginDefragmentation = c.vmaBeginDefragmentation;
pub const endDefragmentation = c.vmaEndDefragmentation;
pub const beginDefragmentationPass = c.vmaBeginDefragmentationPass;
pub const endDefragmentationPass = c.vmaEndDefragmentationPass;
pub const bindBufferMemory = c.vmaBindBufferMemory;
pub const bindBufferMemory2 = c.vmaBindBufferMemory2;
pub const bindImageMemory = c.vmaBindImageMemory;
pub const bindImageMemory2 = c.vmaBindImageMemory2;
pub const createBuffer = c.vmaCreateBuffer;
pub const createBufferWithAlignment = c.vmaCreateBufferWithAlignment;
pub const createAliasingBuffer = c.vmaCreateAliasingBuffer;
pub const createAliasingBuffer2 = c.vmaCreateAliasingBuffer2;
pub const destroyBuffer = c.vmaDestroyBuffer;
pub const createImage = c.vmaCreateImage;
pub const createAliasingImage = c.vmaCreateAliasingImage;
pub const createAliasingImage2 = c.vmaCreateAliasingImage2;
pub const destroyImage = c.vmaDestroyImage;
pub const createVirtualBlock = c.vmaCreateVirtualBlock;
pub const destroyVirtualBlock = c.vmaDestroyVirtualBlock;
pub const isVirtualBlockEmpty = c.vmaIsVirtualBlockEmpty;
pub const getVirtualAllocationInfo = c.vmaGetVirtualAllocationInfo;
pub const virtualAllocate = c.vmaVirtualAllocate;
pub const virtualFree = c.vmaVirtualFree;
pub const clearVirtualBlock = c.vmaClearVirtualBlock;
pub const setVirtualAllocationUserData = c.vmaSetVirtualAllocationUserData;
pub const getVirtualBlockStatistics = c.vmaGetVirtualBlockStatistics;
pub const calculateVirtualBlockStatistics = c.vmaCalculateVirtualBlockStatistics;
pub const buildVirtualBlockStatsString = c.vmaBuildVirtualBlockStatsString;
pub const freeVirtualBlockStatsString = c.vmaFreeVirtualBlockStatsString;
pub const buildStatsString = c.vmaBuildStatsString;
pub const freeStatsString = c.vmaFreeStatsString;
