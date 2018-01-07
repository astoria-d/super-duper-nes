
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define TTY "/dev/ttyNES0"
#define SHELL "/bin/bash"

int main (int argc, char* argv[]) {
    int ret;
    pid_t pid;

    printf("%s started....\n", argv[0]);
    printf("press ctrl-c to terminate.\n");

    pid = fork();
    if (pid == -1 ) {
        /*fork failed*/
        printf("child process create error.\n");
        return -1;
    }
    else if (pid == 0) {
        /*child.*/
        char* c_argv[] = {NULL};
        int fd;

        printf("execute child shell..\n");

        /*open standard in/out*/
        fd = open(TTY, O_RDWR | O_NONBLOCK | O_NOCTTY);
        if (fd == -1) {
            printf("tty [%s] open failed.\n", TTY);
            return -1;
        }
        close(STDIN_FILENO);
        close(STDOUT_FILENO);
        close(STDERR_FILENO);
        dup2(fd, STDIN_FILENO);
        dup2(fd, STDOUT_FILENO);
        dup2(fd, STDERR_FILENO);
        /*printf("new fd...\n");*/
        execv(SHELL, c_argv);
        close(fd);
    }
    else {
        /*parent..*/
        wait(NULL);
        printf("parent done..\n");
    }

    return 0;
}

