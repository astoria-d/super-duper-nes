#include <stdio.h>
#include <unistd.h>

int main(int argc, char* argv[]) {

    int len;
    unsigned char ch;
/*    printf("0x%02x \n", ch);*/
    while ((len = read(0, &ch, 1)) > 0){
        printf("0x%02x ", ch);
    }
    return 0;
}
