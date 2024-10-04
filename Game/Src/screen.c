#include "dma2d.h"
#include "stm32f4xx_hal.h"
#include "stm32f4xx_hal_dma2d.h"
#include <stdint.h>

#define SCREEN_WIDHT 320
#define SCREEN_HEIGHT 240

static uint32_t screen_buffer[SCREEN_WIDHT][SCREEN_HEIGHT] __attribute__((section(".sdram")));

void screen_write_pixel(uint32_t Xpos, uint32_t Ypos, uint32_t color) {
    screen_buffer[Ypos][SCREEN_HEIGHT - Xpos] = color;
}

void screen_clear(uint32_t color) {
    hdma2d.Init.Mode = DMA2D_R2M;
    /* DMA2D Initialization */
    if (HAL_DMA2D_Init(&hdma2d) != HAL_OK) {
      /* Initialization Error */
      BSP_LED_On(1);
    }
    unsigned int address = getLtdcHandler().LayerCfg[getActiveLayer()].FBStartAdress;
    uint32_t clear_color = color;
    HAL_DMA2D_Start(&hdma2d, clear_color, screen_buffer, 240, 320);
    HAL_DMA2D_PollForTransfer(&hdma2d, 10);
    HAL_DMA2D_DeInit(&hdma2d);
}

void screen_flush() {
    hdma2d.Init.Mode = DMA2D_M2M;
    /* DMA2D Initialization */
    if (HAL_DMA2D_Init(&hdma2d) != HAL_OK) {
      /* Initialization Error */
      BSP_LED_On(1);
    }
    unsigned int address = getLtdcHandler().LayerCfg[getActiveLayer()].FBStartAdress;
    if (HAL_DMA2D_Start(&hdma2d, (uint32_t)&screen_buffer[0], (uint32_t)address, 240, 320) != HAL_OK) {
    }
    HAL_DMA2D_PollForTransfer(&hdma2d, 10);
    HAL_DMA2D_DeInit(&hdma2d);
}
