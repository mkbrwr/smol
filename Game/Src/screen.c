#include "dma2d.h"
#include "stm32f4xx_hal.h"
#include "stm32f4xx_hal_dma2d.h"
#include <stdint.h>

#define SCREEN_WIDHT 320
#define SCREEN_HEIGHT 240

#define FLUSHING 42
#define CLEANING 43
#define WAITING 44

static uint32_t screen_buffer[SCREEN_WIDHT][SCREEN_HEIGHT] __attribute__((section(".sdram")));

void screen_write_pixel(uint32_t Xpos, uint32_t Ypos, uint32_t color) {
  screen_buffer[Ypos][SCREEN_HEIGHT - Xpos] = color;
}

void TransferComplete(DMA2D_HandleTypeDef *hdma2d);
void TransferError(DMA2D_HandleTypeDef *hdma2d);

int action = WAITING;

void prepare_dma2d_for_cleaning() {
  hdma2d.Init.Mode = DMA2D_R2M;
  /* DMA2D Callbacks Configuration */
  hdma2d.XferCpltCallback = TransferComplete;
  hdma2d.XferErrorCallback = TransferError;
  /* DMA2D Initialization */
  if (HAL_DMA2D_Init(&hdma2d) != HAL_OK) {
    /* Initialization Error */
    BSP_LED_On(1);
  }
}
void prepare_dma2d_for_flushing() {
  hdma2d.Init.Mode = DMA2D_M2M;
  /* DMA2D Callbacks Configuration */
  hdma2d.XferCpltCallback = TransferComplete;
  hdma2d.XferErrorCallback = TransferError;

  /* DMA2D Initialization */
  if (HAL_DMA2D_Init(&hdma2d) != HAL_OK) {
    /* Initialization Error */
    BSP_LED_On(1);
  }
}

void screen_clear(uint32_t color) {
  unsigned int address =
      getLtdcHandler().LayerCfg[getActiveLayer()].FBStartAdress;
  uint32_t clear_color = color;
  if (HAL_DMA2D_Start_IT(&hdma2d, clear_color, screen_buffer, 240, 320) !=
      HAL_OK) {
  }
  action = CLEANING;
}

void screen_flush() {
  unsigned int address =
      getLtdcHandler().LayerCfg[getActiveLayer()].FBStartAdress;
  if (HAL_DMA2D_Start_IT(&hdma2d, (uint32_t)&screen_buffer[0],
                         (uint32_t)address, 240, 320) != HAL_OK) {
  }
  action = FLUSHING;
}

void show_frame() {
  if (action == WAITING) {
    prepare_dma2d_for_flushing();
    screen_flush();
  }
}

void TransferComplete(DMA2D_HandleTypeDef *handle) {
  /* Turn LED1 On */
  BSP_LED_On(0);
  if (action == FLUSHING) {
    prepare_dma2d_for_cleaning();
    screen_clear(0xff000000);
  } else if (action == CLEANING) {
    prepare_dma2d_for_flushing();
    action = WAITING;
  }
}

void TransferError(DMA2D_HandleTypeDef *hdma2d) {
  /* Turn LED3 On */
  BSP_LED_On(1);
}
