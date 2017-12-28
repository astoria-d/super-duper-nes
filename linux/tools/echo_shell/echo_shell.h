
#ifndef __echo_shell_h__
#define __echo_shell_h__

#include <semaphore.h>

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

#define RT_OK 0
#define RT_ERROR -1


#define ASCII_0 48
#define ASCII_1 49


#ifdef ENV_CYGWIN
#define GPIO_DEVICE "./gpio115"
#else
#define GPIO_DEVICE "/sys/class/gpio/gpio115/value"
#endif


typedef void (*dummy_handler_t) (unsigned int param);

int register_gpio_handler(dummy_handler_t func);
void unregister_gpio_handler(void);
void gpio_handler_func (unsigned int param);

int create_i2c_terminal(void);
void destroy_i2c_terminal(void);

extern sem_t echo_shell_sem;

#endif

