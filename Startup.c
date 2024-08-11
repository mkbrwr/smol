#include <stdint.h>
#include <stddef.h>

extern int main(int argc, char *argv[]);

void Reset_Handler(void) {
    main(0, NULL);
}

void interrupt(void) {
    while (1) {}
}

__attribute((used)) __attribute((section(".isr_vector")))
void *vector_table[114] = {
    (void *)0x2000fffc, // initial SP
    Reset_Handler, // Reset

    interrupt, // NMI
    interrupt, // HardFault
    interrupt, // MemManage
    interrupt, // BusFault
    interrupt, // UsageFault
    
    0 // NULL for all the other handlers
};
