#ifndef _BRIDGING_HEADER
#define _BRIDGING_HEADER
#include <stdint.h>

// Debug
typedef enum
{
  GREEN_LED = 0,
  RED_LED = 1
} Led_TypeDef;

void HAL_Delay(uint32_t Delay);
void BSP_LED_On(Led_TypeDef Led);
void BSP_LED_Off(Led_TypeDef Led);
void BSP_LED_Toggle(Led_TypeDef Led);
unsigned SEGGER_RTT_WriteString(unsigned BufferIndex, const char* s);

// Provides a tick value in milliseconds.
uint32_t HAL_GetTick(void);

// From screen.h
void screen_clear(uint32_t color);
void screen_write_pixel(uint32_t Xpos, uint32_t Ypos, uint32_t color);
uint32_t screen_read_pixel(uint32_t Xpos, uint32_t Ypos);
void screen_flush();

// Sprites
uint32_t getSwiftLogoPixelDataAt(uint32_t idx);
uint32_t getAlienPixelDataAt(uint32_t idx);
uint32_t getZombiePixelDataAt(uint32_t idx);


#endif
