
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("astoria-d");
MODULE_DESCRIPTION("super-duper-nes simple Linux driver.");
MODULE_VERSION("0.1");

static char *name = "astr-sample";
module_param(name, charp, S_IRUGO);
MODULE_PARM_DESC(name, "The name to display in /var/log/kern.log");

static int __init helloBBB_init(void){
       printk(KERN_INFO "test...%s\n", name);
          return 0;
}

static void __exit helloBBB_exit(void){
       printk(KERN_INFO "done %s\n", name);
}

module_init(helloBBB_init);
module_exit(helloBBB_exit);

