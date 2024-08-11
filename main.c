#include <stdint.h>

int main(void)
{
  // (1) enable clock
  *((uint32_t *)(0x40023800 + 0x30)) = 0x40;

  // (2) set mode to output
  *((uint32_t *)(0x40021800 + 0x00)) = 0x4000000;

  // led off
  *((uint32_t *)(0x40021800 + 0x18)) = 0x20000000;
  
  while (1) {
    // led on
    *((uint32_t *)(0x40021800 + 0x18)) = 0x2000;
    for (volatile int i = 0; i < 100000; i++) {
    }
    // led off
    *((uint32_t *)(0x40021800 + 0x18)) = 0x20000000;
    for (volatile int i = 0; i < 300000; i++) {
    }
  }
}