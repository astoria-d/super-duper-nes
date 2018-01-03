
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/of.h>
#include <linux/i2c.h>

#include "bbb_tty.h"

/*
   driver prove/remove not working...
   must consider alternative method to access platform device...
*/
static int bt_i2c_probe (struct i2c_client *client, const struct i2c_device_id *id) {

    printk(KERN_INFO "bt_i2c_probe.\n");
    return 0;
}

static int bt_i2c_remove(struct i2c_client *client) {
    printk(KERN_INFO "bt_i2c_remove.\n");
    return 0;
}

static const struct bt_platform_data bt_pdata = {
    .data = 1,
};

static const struct i2c_device_id bt_id_table[] = {
    {"duper_nes", 0 },
    { }
};
MODULE_DEVICE_TABLE(i2c, bt_id_table);
/*
*/

/*
static struct i2c_board_info duper_nes_devices[] = {
    {
        .type = "duper_nes",
        .addr = 0x31,
    },
};
*/


static struct i2c_driver  bt_i2c_driver = {
    .driver     = {
        .name   = "duper_nes",
    },
    .probe      = bt_i2c_probe,
    .remove     = bt_i2c_remove,
    .id_table = bt_id_table,
};


static struct i2c_client *client;

int bt_i2c_init(void){
    int ret;
    struct i2c_adapter *adapter;

    /*ret = i2c_register_board_info(1, duper_nes_devices, ARRAY_SIZE(duper_nes_devices));
    printk(KERN_INFO "register i2c board ret:%d.\n", ret);*/

    ret = i2c_add_driver(&bt_i2c_driver);
    printk(KERN_INFO "add i2c driver ret:%d.\n", ret);

    /*
    struct i2c_board_info info = {
        .type = "bbb_tty_core",
        .addr = 0x44,
    };

    adapter = i2c_get_adapter(1);
    if (!adapter) return -EINVAL;

    client = i2c_new_device(adapter, &info);
    if (!client) return -EINVAL;
*/

    return 0;
}

void bt_i2c_exit(void){
    i2c_del_driver(&bt_i2c_driver);
    printk(KERN_INFO "bt_i2c_exit.\n");
}

