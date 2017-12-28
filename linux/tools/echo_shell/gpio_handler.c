
#include <stdio.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include "echo_shell.h"

/*sleep 1 msec.*/
#define SLEEP_INTERVAL 1000000


void* gpio_polling(void* param);

static pthread_t gpio_thread_id;
static int exit_loop;
static dummy_handler_t gpio_handler;


int register_gpio_handler(dummy_handler_t func) {
    int ret;
    pthread_attr_t attr;

    ret = pthread_attr_init(&attr);
    if (ret != RT_OK)
        return FALSE;

    gpio_thread_id = 0;
    exit_loop = FALSE;
    gpio_handler = func;
    ret = pthread_create(&gpio_thread_id, &attr, gpio_polling, NULL);
    if (ret != RT_OK)
        return FALSE;

#ifdef ENV_CYGWIN
    printf("dummy gpio reader started.\n");
    printf("emulate gpio pin status by setting values on dummy file %s.\n", GPIO_DEVICE);
#endif

    return TRUE;
}


void unregister_gpio_handler(void) {
    exit_loop = TRUE;
    pthread_join(gpio_thread_id, NULL);

/**/    printf("unregister gpio handler ok.\n");
}


void* gpio_polling(void* param) {
    while (!exit_loop) {
        struct timespec ts = {0, SLEEP_INTERVAL};
        int fd;
        int len;
        unsigned char pin_val;

        /*check gpio pin status.*/
        fd = open(GPIO_DEVICE, O_RDONLY);
        if (fd == -1) {
            ts.tv_sec = 1;
            nanosleep(&ts, NULL);
            continue;
        }
        len = read(fd, &pin_val, 1);
        /*printf("chk1, %d, val=%d\n", len, pin_val);*/
        if (len == 1) {
            if (pin_val == ASCII_0) {
                (*gpio_handler)(BBB_FIFO_NOT_EMPTY);
            }
        }
        close (fd);
        nanosleep(&ts, NULL);
    }
    /*printf("exit gpio thread.\n");*/
}



void gpio_handler_func (unsigned int gpio_val){
    if (gpio_val == BBB_FIFO_NOT_EMPTY) {
/*        printf("gpio data arrived.\n");*/
        sem_post(&echo_shell_sem);
    }
}

int gpio_check(void) {
    int fd;

    fd = open(GPIO_DEVICE, O_RDONLY);
    if (fd != 0) {
        int len;
        unsigned char pin_val;

        len = read(fd, &pin_val, 1);
        close (fd);

        if (len == 1) {
            if (pin_val == ASCII_0) {
                return BBB_FIFO_NOT_EMPTY;
            }
            else {
                return BBB_FIFO_EMPTY;
            }
        }
    }
    else {
        return BBB_FIFO_EMPTY;
    }
}

