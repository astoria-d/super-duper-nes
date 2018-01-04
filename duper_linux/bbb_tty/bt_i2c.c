
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/of.h>
#include <linux/i2c.h>

#include "bbb_tty.h"


static struct i2c_client *client;

int bt_i2c_proc_show(struct seq_file *seq, void *offset) {
    struct i2c_msg msg[1];
    u8 recvdata;
    u8 senddata;
    int ret;

    seq_printf(seq, "client info: @%p\n", client);
    if (!client) return 0;

    seq_printf(seq, "   name: [%s]\n", client->name);
    seq_printf(seq, "   flags: %04x\n", client->flags);
    seq_printf(seq, "   addr: %04x\n", client->addr);
    seq_printf(seq, "   irq: %d\n", client->irq);

    /*test read i2c bus.*/
    memset(msg, 0, sizeof(msg));
    msg[0].addr = client->addr;
    msg[0].flags = I2C_M_RD;
    msg[0].buf = &recvdata;
    msg[0].len = 1;

    ret = i2c_transfer(client->adapter, msg, 1);
    seq_printf(seq, "   test i2c read. ret: %d, data: %02x\n", ret, recvdata);

    senddata = 'd';
    ret = i2c_master_send(client, &senddata, 1);
    seq_printf(seq, "   test i2c write. ret: %d, data: %02x is sent.\n", ret, senddata);
    return 0;
}

static int bt_i2c_probe (struct i2c_client *cl, const struct i2c_device_id *id) {
    client = cl;
    printk(KERN_INFO "bt_i2c_probe %p.\n", cl);
    return 0;
}

static int bt_i2c_remove(struct i2c_client *cl) {
    client = NULL;
    printk(KERN_INFO "bt_i2c_remove %p.\n", cl);
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
        /*private data (not set at this moment..)*/
        .p      = NULL,
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

