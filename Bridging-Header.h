#ifndef _BRIDGING_HEADER
#define _BRIDGING_HEADER

#include <stdint.h>

void HAL_Delay(uint32_t Delay);
void BSP_LED_On(uint32_t Led);
void BSP_LED_Off(uint32_t Led);
void BSP_LED_Toggle(uint32_t Led);


#include <stddef.h>

void *malloc(size_t);
void free(void*);

#endif
