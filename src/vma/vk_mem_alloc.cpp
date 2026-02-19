// VMA implementation file.
// Compiled as C++17 and linked into the vma static library.
#define VMA_IMPLEMENTATION
// Disable VMA's automatic Vulkan function loading.
// Users must provide function pointers explicitly via VmaVulkanFunctions.
#define VMA_STATIC_VULKAN_FUNCTIONS 0
#define VMA_DYNAMIC_VULKAN_FUNCTIONS 0
#include "vk_mem_alloc.h"
