
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/of.h>
#include <linux/i2c.h>

#include "bbb_tty.h"


static struct i2c_client *client;

static int bt_i2c_probe (struct i2c_client *cl, const struct i2c_device_id *id) {

    client = cl;
    printk(KERN_INFO "bt_i2c_probe.\n");
    return 0;
}

static int bt_i2c_remove(struct i2c_client *cl) {
    client = NULL;
    printk(KERN_INFO "bt_i2c_remove.\n");
    return 0;
}

static const struct i2c_device_id bt_id_table[] = {
    /*this id must match with the dts entry.*/
    {"duper_nes", 0 },
    { }
};
MODULE_DEVICE_TABLE(i2c, bt_id_table);


static struct i2c_driver  bt_i2c_driver = {
    .driver     = {
        .name   = "bbb_tty_drv",
    },
    .probe      = bt_i2c_probe,
    .remove     = bt_i2c_remove,
    .id_table = bt_id_table,
};

int bt_i2c_init(void){
    int ret;

    client = NULL;
    ret = i2c_add_driver(&bt_i2c_driver);
    printk(KERN_INFO "add i2c driver ret:%d.\n", ret);

    return 0;
}

void bt_i2c_exit(void){
    i2c_del_driver(&bt_i2c_driver);
    printk(KERN_INFO "bt_i2c_exit.\n");
}

