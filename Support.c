//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#if defined(__arm__)

#include <stdint.h>
#include <stddef.h>

#define HEAP_SIZE (2 * 1024 * 1024)

char* heap = (char*)0xD02AB000;
size_t next_heap_index = 0;

void *calloc(size_t count, size_t size) {
  if (next_heap_index + count * size > HEAP_SIZE) __builtin_trap();
  void *p = &heap[next_heap_index];
  next_heap_index += count * size;
  return p;
}

int posix_memalign(void **memptr, size_t alignment, size_t size) {
  *memptr = calloc(size + alignment, 1);
  if (((uintptr_t)*memptr) % alignment == 0) return 0;
  *(uintptr_t *)memptr += alignment - ((uintptr_t)*memptr % alignment);
  return 0;
}

void free(void *ptr) {
  while (1) {
      HAL_Delay(100);
      BSP_LED_Toggle(1);
      HAL_Delay(100);
  }
}

void *memset(void *b, int c, size_t len) {
  for (int i = 0; i < len; i++) {
    ((char *)b)[i] = c;
  }
  return b;
}

void *memcpy(void *restrict dst, const void *restrict src, size_t n) {
  for (int i = 0; i < n; i++) {
    ((char *)dst)[i] = ((char *)src)[i];
  }
  return dst;
}

#endif
