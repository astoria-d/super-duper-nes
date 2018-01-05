
#include <linux/module.h>
#include <linux/seq_file.h>
#include <linux/proc_fs.h>
#include <asm/uaccess.h>

#include "bbb_tty.h"

#define PROC_ENT "driver/bbb-tty-test"

static int bt_proc_show(struct seq_file *seq, void *offset) {
    int ret;

    printk(KERN_INFO "bt_proc_show...\n");

    seq_printf(seq, "bbb tty proc test...\n");

    ret = bt_i2c_proc_show(seq, offset);
    if (ret) return ret;
    ret = bt_gpio_proc_show(seq);

    return ret;
}

static int bt_proc_open(struct inode *inode, struct file *file) {
    int ret;

    if (!try_module_get(THIS_MODULE))
        return -ENODEV;

    ret = single_open(file, bt_proc_show, NULL);

    if (ret)
        module_put(THIS_MODULE);

    printk(KERN_INFO "single_open ret:%d.\n", ret);
    return ret;
}

static int bt_proc_release(struct inode *inode, struct file *file) {
    int ret;
    ret = single_release(inode, file);
    module_put(THIS_MODULE);
    printk(KERN_INFO "single_release ret:%d.\n", ret);
    return ret;
}

static const struct file_operations by_proc_fops = {
    .open       = bt_proc_open,
    .read       = seq_read,
    .release    = bt_proc_release,
};


int bt_proc_init(void){
    proc_create_data(PROC_ENT, 0, NULL, &by_proc_fops, NULL);
    return 0;
}

void bt_proc_exit(void){
    remove_proc_entry(PROC_ENT, NULL);
}

