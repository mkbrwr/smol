#ifndef _BRIDGING_HEADER
#define _BRIDGING_HEADER
#include <stdint.h>

int siuuufoo();

typedef struct {
  char a;
  char r;
  char g;
  char b;
} ScreenColor;

typedef enum
{
  LED3 = 0,
  LED4 = 1
} Led_TypeDef;


uint32_t getPixelDataAt(uint32_t w, uint32_t h);
void HAL_Delay(uint32_t Delay);
void BSP_LED_Toggle(Led_TypeDef Led);

void screen_clear(ScreenColor color);
void screen_write_pixel(unsigned int Xpos, unsigned int Ypos, ScreenColor color, float in_pixel_depth);
void screen_flush(void);

#endif
