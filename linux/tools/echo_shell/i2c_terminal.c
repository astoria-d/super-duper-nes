
#include <stdio.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>

#ifndef ENV_CYGWIN
#include <sys/ioctl.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#endif

#include "echo_shell.h"

#ifdef ENV_CYGWIN
#define I2C_DEVICE "./i2c-2"
#else
#define I2C_DEVICE "/dev/i2c-2"
#define DUPER_ADDR 0x44
#endif

static int exit_loop;
static pthread_t i2c_thread_id;

void* i2c_term_loop(void* param) {
    while (!exit_loop) {
        int fd_i2c;
        int ret;
#ifdef ENV_CYGWIN
        int fd_gpio;
#endif

        /*printf("i2c loop...\n");*/
        ret = sem_wait(&echo_shell_sem);
        /*printf("i2c data received.\n");*/
        if (ret == -1) {
            /*case kill signal.*/
            break;
        }

        fd_i2c = open(I2C_DEVICE, O_RDONLY);
        if (fd_i2c != 0) {
            int len;
            unsigned char i2c_ch;

            /*printf("i2c open.\n");*/
#ifndef ENV_CYGWIN
            /*select slave address*/
            ioctl(fd_i2c, I2C_SLAVE, DUPER_ADDR);
#endif

            while (len = (read (fd_i2c, &i2c_ch, 1) ) > 0) {
                printf("%02x\n", i2c_ch);
            }
            close (fd_i2c);
        }

#ifdef ENV_CYGWIN
        /*clear gpio flag when data is empty*/
        fd_gpio = open(GPIO_DEVICE, O_WRONLY);
        if (fd_gpio != 0) {
            unsigned char ch = ASCII_1;
            write (fd_gpio, &ch, 1);
            close (fd_gpio);
        }
#endif
    }

    return NULL;
}


int create_i2c_terminal(void) {
    int ret;
    pthread_attr_t attr;

    printf("i2c terminal initialize.\n");
#ifdef ENV_CYGWIN
    printf("nes incoming data is emulated by the dummy device file %s.\n", I2C_DEVICE);
#endif

    ret = pthread_attr_init(&attr);
    if (ret != RT_OK)
        return FALSE;

    i2c_thread_id = 0;
    exit_loop = FALSE;
    ret = pthread_create(&i2c_thread_id, &attr, i2c_term_loop, NULL);
    if (ret != RT_OK)
        return FALSE;

    return TRUE;
}

void destroy_i2c_terminal(void) {
    exit_loop = TRUE;
/*
    int sval;
    sem_getvalue(&echo_shell_sem, &sval);
 */
    /*printf("i2c terminal destroy sval=%d.\n", sval);*/

    pthread_kill(i2c_thread_id, SIGTERM);
    pthread_join(i2c_thread_id, NULL);
    printf("exit i2c terminal thread.\n");
}

