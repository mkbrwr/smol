#ifndef __SCREEN_H
#define __SCREEN_H

#define SCREEN_WIDHT 320
#define SCREEN_HEIGHT 240

typedef struct {
  char a;
  char r;
  char g;
  char b;
} ScreenColor;

void screen_clear(ScreenColor color);
void screen_write_pixel(unsigned int Xpos, unsigned int Ypos, ScreenColor color, float in_pixel_depth);
void screen_flush(void);

#endif /*__SCREEN_H */
