
#include <stdio.h>
#include <stdlib.h>

void cmd_exec(const char* cmd) {
    FILE* outp;
    char ch;

/*
    system(cmd);
*/
    printf("%s\n", cmd);
    outp = popen(cmd, "r");
    while (fread(&ch, 1, 1, outp) > 0) {
        printf("%c", ch);
    }
    pclose(outp);
}

