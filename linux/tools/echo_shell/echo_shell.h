
#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

#define RT_OK 0
#define RT_ERROR -1


typedef void (*dummy_handler_t) (unsigned int param);

int register_gpio_handler(dummy_handler_t func);
void unregister_gpio_handler(void);
void gpio_handler_func (unsigned int param);

