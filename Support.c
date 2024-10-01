#include <stddef.h>

int posix_memalign(void **res, size_t align, size_t len)
{
	if (align < sizeof(void *)) return my_fatal_error(21);
	void *mem = aligned_alloc(align, len);
	if (!mem) return my_fatal_error(22);
	*res = mem;
	return 0;
}

void my_fatal_error(int code) {
    if (code == 21) {
        BSP_LED_On(0);
    } else if (code == 22) {
        BSP_LED_On(1);
    } else {
        BSP_LED_On(0);
        BSP_LED_On(1);
    }
    while (1) {};
}
