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

// From screen.h
void screen_clear(uint32_t argb);
void screen_write_pixel(uint32_t Xpos, uint32_t Ypos, uint32_t argb);
void screen_flush(void);

// Swift Logo
uint32_t getSwiftLogoPixelDataAt(uint32_t idx);

// Debug
unsigned SEGGER_RTT_WriteString(unsigned BufferIndex, const char* s);

/**
  * @brief Provides a tick value in millisecond.
  * @note This function is declared as __weak to be overwritten in case of other
  *       implementations in user file.
  * @retval tick value
  */
uint32_t HAL_GetTick(void);

#endif
