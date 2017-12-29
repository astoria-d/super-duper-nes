
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "echo_shell.h"

#define BUF_MAX 1024

void cmd_exec(const char* cmd) {
    FILE* outp;
    char buf[BUF_MAX];

/*
    system(cmd);
*/
    console_print(cmd);
    console_print("\n");
    outp = popen(cmd, "r");
    memset(buf, 0, BUF_MAX);
    while (fread(buf, BUF_MAX, 1, outp) > 0) {
        printf("%s", buf);
        memset(buf, 0, BUF_MAX);
    }
    pclose(outp);
}

