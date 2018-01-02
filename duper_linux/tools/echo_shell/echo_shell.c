
#include <string.h>
#include <stdio.h>
#include <signal.h>
#include <time.h>

#include "echo_shell.h"

static int main_loop_done;

sem_t echo_shell_sem;

static void sig_handler(int sig) {
    main_loop_done = TRUE;
}


static int prepare_sig(void) {
    struct sigaction sigact;

    memset(&sigact, 0, sizeof(struct sigaction));
    sigact.sa_handler = sig_handler;
    if ( sigemptyset(&sigact.sa_mask) ) {
        return FALSE;
    }
    if ( sigaction(SIGINT, &sigact, NULL) ) {
        return FALSE;
    }

    return TRUE;
}


int main (int argc, char* argv[]) {
    int ret;

    printf("%s started....\n", argv[0]);
    printf("press ctrl-c to terminate.\n");

    main_loop_done = FALSE;
    /*
    register the Ctrl-C signal handler.
     */
    ret = prepare_sig();
    if (!ret) {
        fprintf(stderr, "signal handling error...\n");
        return RT_ERROR;
    }

    ret = sem_init(&echo_shell_sem, 0, 0);
    if (ret != RT_OK) {
        fprintf(stderr, "semaphore init error...\n");
        return RT_ERROR;
    }

    ret = register_gpio_handler(gpio_handler_func);
    if (!ret) {
        fprintf(stderr, "gpio handler init error...\n");
        return RT_ERROR;
    }

    ret = create_i2c_terminal();
    if (!ret) {
        fprintf(stderr, "i2c terminal init error...\n");
        unregister_gpio_handler();
        return RT_ERROR;
    }

    /*setbuf(stdout, NULL);*/
    while (!main_loop_done) {
        /*printf(".");*/
        /*just wait for kill signal to be issued...*/
        struct timespec ts = {10, 0};
        nanosleep(&ts, NULL);
    }
    unregister_gpio_handler();
    destroy_i2c_terminal();
    sem_destroy(&echo_shell_sem);

    printf("%s done.\n", argv[0]);
    return RT_OK;
}

