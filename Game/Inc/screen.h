#ifndef __SCREEN_H
#define __SCREEN_H
#include <stdint.h>

#define SCREEN_WIDHT 320
#define SCREEN_HEIGHT 240

void screen_clear(uint32_t argb);
void screen_write_pixel(uint32_t Xpos, uint32_t Ypos, uint32_t argb);
void screen_flush(void);

#endif /*__SCREEN_H */
