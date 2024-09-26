#include <stdint.h>
#include "screen.h"
#include "dma2d.h"
#include "stm32f4xx_hal.h"

static uint32_t colorBuffer[SCREEN_WIDHT][SCREEN_HEIGHT] __attribute__((section(".sdram")));

// X starts at lower left corner and goes left
// Y starts at lower left cornect and goes up
void screen_write_pixel(uint32_t Xpos, uint32_t Ypos, uint32_t color)
{
  colorBuffer[Ypos][Xpos] = color;
}

void screen_flush(void)
{
  hdma2d.Init.Mode = DMA2D_M2M;
  hdma2d.Init.ColorMode = DMA2D_ARGB8888;

  MODIFY_REG(hdma2d.Instance->CR, DMA2D_CR_MODE, DMA2D_M2M);
  MODIFY_REG(hdma2d.Instance->OPFCCR, DMA2D_OPFCCR_CM, DMA2D_ARGB8888);
  MODIFY_REG(hdma2d.Instance->OOR, DMA2D_OOR_LO, BSP_LCD_GetXSize() - 240);

  hdma2d.LayerCfg[1].InputColorMode = CM_ARGB8888;
  hdma2d.LayerCfg[1].InputOffset = 0;

  HAL_DMA2D_ConfigLayer(&hdma2d, 1);

  unsigned int address = getLtdcHandler().LayerCfg[getActiveLayer()].FBStartAdress;

  HAL_DMA2D_Start_IT(&hdma2d, (uint32_t)&colorBuffer[0], (unsigned int)address, 240, 320);
}

void screen_clear(uint32_t color)
{
  for (int i = 0; i < SCREEN_WIDHT; i += 1) {
    for (int j = 0; j < SCREEN_HEIGHT; j += 1) {
      colorBuffer[i][j] = color;
    }
  }
}
