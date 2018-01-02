
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>

#include "bbb_tty.h"

/*
   driver prove/remove not working...
   must consider alternative method to access platform device...
*/
static int bt_i2c_probe(struct platform_device *pdev) {
    struct resource *res;

    printk(KERN_INFO "bt_i2c_probe.\n");
    res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!res) {
        printk(KERN_INFO "platform_get_resource failed..\n");
    }
    printk(KERN_INFO "res:%08x..\n", (unsigned int)res);

    return 0;
}

static int bt_i2c_remove(struct platform_device *pdev) {
    printk(KERN_INFO "bt_i2c_remove.\n");
    return 0;
}

static const struct bt_platform_data bt_pdata = {
    .data = 1,
};

/*
static const struct of_device_id bt_match[] = {
    {
        .compatible = "bbb_tty",
        .data = &bt_pdata,
    },
    { },
};
MODULE_DEVICE_TABLE(of, bt_match);
*/

static const struct platform_device_id bt_id_table[] = {
    {
        .name       = "bbb_tty_drv",
        .driver_data    = &bt_pdata,
    },
    { }
};
MODULE_DEVICE_TABLE(platform, bt_id_table);


static struct platform_driver bt_i2c_driver = {
    .probe      = bt_i2c_probe,
    .remove     = bt_i2c_remove,
    .driver     = {
        .name   = "bbb_tty",
    },
    .id_table = bt_id_table,
};

/*
module_platform_driver(bt_i2c_driver);
*/

int bt_i2c_init(void){
    int ret;

    ret = platform_driver_register(&bt_i2c_driver);
    printk(KERN_INFO "bt_i2c_init ret:%d.\n", ret);
    return 0;
}

void bt_i2c_exit(void){
    platform_driver_unregister(&bt_i2c_driver);
    printk(KERN_INFO "bt_i2c_exit.\n");
}

