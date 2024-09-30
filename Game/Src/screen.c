#include "dma2d.h"
#include "stm32f4xx_hal.h"
#include <stdint.h>
#include <string.h>

#define SCREEN_WIDHT 320
#define SCREEN_HEIGHT 240

// Foreground layer can be transparent, i.e. has alpha channel

static uint32_t foreground[SCREEN_WIDHT][SCREEN_HEIGHT] __attribute__((section(".sdram")));
static uint32_t background[SCREEN_WIDHT][SCREEN_HEIGHT] __attribute__((section(".sdram")));

void screen_write_pixel_foreground(uint32_t Xpos, uint32_t Ypos, uint32_t color) {
    foreground[Ypos][SCREEN_HEIGHT - Xpos] = color;
}

void screen_write_pixel_background(uint32_t Xpos, uint32_t Ypos, uint32_t color) {
    background[Ypos][SCREEN_HEIGHT - Xpos] = color;
}

void screen_init() {
    /* Configure the DMA2D Mode, Color Mode and output offset */
      hdma2d.Init.Mode         = DMA2D_M2M_BLEND;
      hdma2d.Init.ColorMode    = DMA2D_ARGB8888;
      hdma2d.Init.OutputOffset = 0x0;

      /* Foreground Configuration */
      hdma2d.LayerCfg[1].AlphaMode = DMA2D_NO_MODIF_ALPHA;
      hdma2d.LayerCfg[1].InputColorMode = DMA2D_INPUT_ARGB8888;
      hdma2d.LayerCfg[1].InputOffset = 0x0;

      /* Background Configuration */
      hdma2d.LayerCfg[0].AlphaMode = DMA2D_REPLACE_ALPHA;
      hdma2d.LayerCfg[0].InputAlpha = 0xFF;
      hdma2d.LayerCfg[0].InputColorMode = DMA2D_INPUT_ARGB8888;
      hdma2d.LayerCfg[0].InputOffset = 0x0;

      hdma2d.Instance          = DMA2D;

      /* DMA2D Initialization */
      if(HAL_DMA2D_Init(&hdma2d) != HAL_OK)
      {
        /* Initialization Error */
        // Error_Handler();
        BSP_LED_On(LED4);
        BSP_LED_On(LED3);
      }

      HAL_DMA2D_ConfigLayer(&hdma2d, 0);
      HAL_DMA2D_ConfigLayer(&hdma2d, 1);
}

void screen_flush_blend() {
      unsigned int address = getLtdcHandler().LayerCfg[getActiveLayer()].FBStartAdress;
      if(HAL_DMA2D_BlendingStart(&hdma2d, (uint32_t)&foreground[0], (uint32_t)&background[0], (uint32_t)address, 240, 320) != HAL_OK) {
          /* Initialization Error */
          while(1) {
              BSP_LED_On(1);
          }
      }
      HAL_DMA2D_PollForTransfer(&hdma2d, 10);
}

void screen_fill_background(uint32_t color) {
    for(int i = 0; i < SCREEN_WIDHT ; i++) {
        for(int j = 0; j < SCREEN_HEIGHT; j++) {
            background[i][j] = color;
        }
    }
}

void screen_fill_foreground(uint32_t color) {
    for(int i = 0; i < SCREEN_WIDHT ; i++) {
        for(int j = 0; j < SCREEN_HEIGHT; j++) {
            foreground[i][j] = color;
        }
    }
}
