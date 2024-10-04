#include <stdint.h>
#include <stdbool.h>
#include "dma2d.h"
#include "stm32f4xx_hal.h"
#include "stm32f4xx_hal_dma2d.h"

#define SCREEN_WIDHT 320
#define SCREEN_HEIGHT 240

#define LAYER1_ADDRESS 0xD0130000

uint32_t screen_buffer[SCREEN_WIDHT][SCREEN_HEIGHT] __attribute__((section(".sdram")));

void prepare_dma2d_for_reg2mem() {
  hdma2d.Instance = DMA2D;
  hdma2d.Init.Mode = DMA2D_R2M;
  hdma2d.Init.ColorMode = DMA2D_ARGB8888;
  hdma2d.Init.OutputOffset = 0;

  hdma2d.LayerCfg[1].InputOffset = 0;
  hdma2d.LayerCfg[1].InputColorMode = DMA2D_INPUT_ARGB8888;
  hdma2d.LayerCfg[1].AlphaMode = DMA2D_NO_MODIF_ALPHA;
  hdma2d.LayerCfg[1].InputAlpha = 0;

  /* DMA2D Initialization */
  if (HAL_DMA2D_Init(&hdma2d) != HAL_OK) {
    /* Initialization Error */
    BSP_LED_On(1);
  }

  if (HAL_DMA2D_ConfigLayer(&hdma2d, 1) != HAL_OK) {
    /* Initialization Error */
    BSP_LED_On(1);
  }
}

void prepare_dma2d_for_mem2mem() {
    hdma2d.Instance = DMA2D;
    hdma2d.Init.Mode = DMA2D_M2M;
    hdma2d.Init.ColorMode = DMA2D_ARGB8888;
    hdma2d.Init.OutputOffset = 0;

    hdma2d.LayerCfg[1].InputOffset = 0;
    hdma2d.LayerCfg[1].InputColorMode = DMA2D_INPUT_ARGB8888;
    hdma2d.LayerCfg[1].AlphaMode = DMA2D_NO_MODIF_ALPHA;
    hdma2d.LayerCfg[1].InputAlpha = 0;

  /* DMA2D Initialization */
  if (HAL_DMA2D_Init(&hdma2d) != HAL_OK) {
    /* Initialization Error */
    BSP_LED_On(1);
  }
  if (HAL_DMA2D_ConfigLayer(&hdma2d, 1) != HAL_OK) {
    /* Initialization Error */
    BSP_LED_On(1);
  }
}

// API
void screen_clear(uint32_t color) {
    prepare_dma2d_for_reg2mem();
    uint32_t clear_color = color;
    if (HAL_DMA2D_Start(&hdma2d, clear_color, screen_buffer, 240, 320) != HAL_OK) {}
    HAL_DMA2D_PollForTransfer(&hdma2d, 10);
}

void screen_write_pixel(uint32_t Xpos, uint32_t Ypos, uint32_t color) {
   screen_buffer[Ypos][SCREEN_HEIGHT - Xpos] = color;
}

void screen_flush() {
    prepare_dma2d_for_mem2mem();
    if (HAL_DMA2D_Start(&hdma2d, screen_buffer, LAYER1_ADDRESS, 240, 320) != HAL_OK) {}
    HAL_DMA2D_PollForTransfer(&hdma2d, 10);
}
