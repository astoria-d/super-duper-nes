
#ifndef __bbb_tth_h__
#define __bbb_tth_h__

int bbb_tty_proc_init(void);
void bbb_tty_proc_exit(void);

int bt_i2c_init(void);
void bt_i2c_exit(void);

struct bt_platform_data {
    int data;
};

#endif

