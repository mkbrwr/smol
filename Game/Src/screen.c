#include "dma2d.h"
#include "stm32f4xx_hal.h"
#include "stm32f4xx_hal_dma2d.h"
#include <stdint.h>

#define SCREEN_WIDHT 320
#define SCREEN_HEIGHT 240

static uint32_t foreground_buffer[SCREEN_WIDHT][SCREEN_HEIGHT] __attribute__((section(".sdram")));
static uint32_t clear_buffer[SCREEN_WIDHT][SCREEN_HEIGHT] __attribute__((section(".sdram")));

void screen_write_pixel(uint32_t Xpos, uint32_t Ypos, uint32_t color) {
  foreground_buffer[Ypos][SCREEN_HEIGHT - Xpos] = color;
}

static void TransferError(DMA2D_HandleTypeDef *Dma2dHandle);
static void TransferComplete(DMA2D_HandleTypeDef *Dma2dHandle);

void screen_init(uint32_t clear_color) {
  hdma2d.Instance = DMA2D;

  /* Configure the DMA2D Mode, Color Mode and output offset */
  hdma2d.Init.Mode = DMA2D_M2M;
  hdma2d.Init.ColorMode = DMA2D_ARGB8888;
  hdma2d.Init.OutputOffset = 0x0;

  /* Foreground Configuration */
  hdma2d.LayerCfg[0].AlphaMode = DMA2D_NO_MODIF_ALPHA;
  hdma2d.LayerCfg[0].InputColorMode = DMA2D_INPUT_ARGB8888;
  hdma2d.LayerCfg[0].InputOffset = 0x0;

  hdma2d.XferCpltCallback = TransferComplete;
  hdma2d.XferErrorCallback = TransferError;

  /* DMA2D Initialization */
  if (HAL_DMA2D_Init(&hdma2d) != HAL_OK) {
    /* Initialization Error */
    BSP_LED_On(1);
  }

  HAL_DMA2D_ConfigLayer(&hdma2d, 0);

  for(int i = 0; i < SCREEN_WIDHT ; i++) {
      for(int j = 0; j < SCREEN_HEIGHT; j++) {
          clear_buffer[i][j] = clear_color;
      }
  }
}

void screen_flush() {
  unsigned int address = getLtdcHandler().LayerCfg[getActiveLayer()].FBStartAdress;
  if (HAL_DMA2D_Start(&hdma2d, (uint32_t)&foreground_buffer[0], (uint32_t)address, 240, 320) != HAL_OK) {
  };
  /* Polling For DMA transfer */
  HAL_DMA2D_PollForTransfer(&hdma2d, 10);
}

void screen_clear() {
    unsigned int address = getLtdcHandler().LayerCfg[getActiveLayer()].FBStartAdress;
    if (HAL_DMA2D_Start(&hdma2d, (uint32_t)&clear_buffer[0], (uint32_t)foreground_buffer, 240, 320) != HAL_OK) {
    };
    /* Polling For DMA transfer */
    HAL_DMA2D_PollForTransfer(&hdma2d, 10);
}

// Callbacks
// callback for transfer complete.
static void TransferError(DMA2D_HandleTypeDef *Dma2dHandle) {
  BSP_LED_Toggle(1);
}

// callback for transfer error.
static void TransferComplete(DMA2D_HandleTypeDef *Dma2dHandle) {
  BSP_LED_Toggle(0);
}
