
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "echo_shell.h"

#define BUF_MAX 1024
#define TMP_FILE "/tmp/echo_shell.tmp"

int cmd_exec(const char* cmd) {
    int fd;
    char buf[BUF_MAX];

    /*check if input string is garbege.*/
    if (!isascii(*cmd)) {
        return FALSE;
    }
    console_print(cmd);
    console_print("\n");

    memset(buf, 0, BUF_MAX);
    sprintf(buf, "%s > %s 2>&1", cmd, TMP_FILE);
    /*system func output to be saved in the tmp file.*/
    system(buf);

    /*get output message.*/
    fd = open(TMP_FILE, O_RDONLY);
    if (fd != 0) {
        memset(buf, 0, BUF_MAX);
        while (read(fd, buf, BUF_MAX) > 0) {
            console_print(buf);
            memset(buf, 0, BUF_MAX);
        }
        close(fd);
    }
    /*clear tmp file..*/
    remove(TMP_FILE);

/*
    printf("len:%d\n", strlen(cmd));
    while (*cmd != '\0') {
        printf("%02x\n", *cmd++);
    }
*/
/*
    FILE* outp;
    outp = popen(cmd, "r");
    memset(buf, 0, BUF_MAX);
    while (fread(buf, BUF_MAX, 1, outp) > 0) {
        console_print(buf);
        memset(buf, 0, BUF_MAX);
    }
    pclose(outp);
*/
    return TRUE;
}

