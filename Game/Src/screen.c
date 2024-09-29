#include <stdint.h>
#include "screen.h"
#include "dma2d.h"
#include "stm32f4xx_hal.h"

static uint32_t colorBuffer[SCREEN_WIDHT][SCREEN_HEIGHT] __attribute__((section(".sdram")));

void screen_write_pixel(uint32_t Xpos, uint32_t Ypos, uint32_t color)
{
  colorBuffer[Ypos][SCREEN_HEIGHT - Xpos] = color;
}

void screen_flush(void) {
  /* Configure the DMA2D Mode, Color Mode and output offset */
  hdma2d.Init.Mode         = DMA2D_M2M;
  hdma2d.Init.ColorMode    = DMA2D_ARGB8888;
  hdma2d.Init.OutputOffset = 0;

  /* Foreground Configuration */
  hdma2d.LayerCfg[1].AlphaMode = DMA2D_NO_MODIF_ALPHA;
  hdma2d.LayerCfg[1].InputAlpha = 0xFF;
  hdma2d.LayerCfg[1].InputColorMode = CM_ARGB8888;
  hdma2d.LayerCfg[1].InputOffset = 0;

  hdma2d.Instance = DMA2D;

  unsigned int address = getLtdcHandler().LayerCfg[getActiveLayer()].FBStartAdress;

  /* DMA2D Initialization */
  if (HAL_DMA2D_Init(&hdma2d) == HAL_OK)
  {
    if (HAL_DMA2D_ConfigLayer(&hdma2d, 1) == HAL_OK)
    {
      if (HAL_DMA2D_Start(&hdma2d, (uint32_t)&colorBuffer[0], (unsigned int)address, 240, 320) == HAL_OK)
      {
        /* Polling For DMA transfer */
        HAL_DMA2D_PollForTransfer(&hdma2d, 10);
      }
    }
  }
}

void screen_clear(uint32_t color)
{
  for (int i = 0; i < SCREEN_WIDHT; i += 1) {
    for (int j = 0; j < SCREEN_HEIGHT; j += 1) {
      colorBuffer[i][j] = color;
    }
  }
}
