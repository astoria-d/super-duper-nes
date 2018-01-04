
#ifndef __bbb_tth_h__
#define __bbb_tth_h__

#include <linux/seq_file.h>

int bbb_tty_proc_init(void);
void bbb_tty_proc_exit(void);

int bt_i2c_init(void);
void bt_i2c_exit(void);

int bt_i2c_proc_show(struct seq_file *seq, void *offset);

struct bt_platform_data {
    int data;
};

#endif

