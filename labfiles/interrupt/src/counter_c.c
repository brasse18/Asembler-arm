#include <linux/module.h>		// Needed to make kernel module
#include <linux/kernel.h>		// Needed for KERN_INFO
#include <linux/interrupt.h>	// Needed for register_irq

#define IRQ 176	// Byt ut 0 mot rätt IRQ


void set_high( void );

void set_low( void );


/*
* Enables access to the gpio
*/
void setup( void );

/*
* Disables access to the GPIO
*/
void setdown( void );

/*
* Interrupt service routine
*/
irqreturn_t counter_isr(int,void*);

/*
* Module init function
*/

static int __init btnrpi_init(void)
{

  setup();
  //set_high();

  printk(KERN_INFO "COUNTER - Driver initialized BEFORE LOOP.\n");

  // for (i = 0; i < 1000000; i++)
  // {
  //   printk(KERN_INFO "LOOP: %d .\n", i);
  //   i++;
  //   i--;
  // }
  //set_low();
  printk(KERN_INFO "COUNTER - Driver initialized.\n");


  if(request_irq(IRQ, counter_isr, IRQF_TRIGGER_FALLING, "counter#btn", NULL))
  {
    printk(KERN_ERR "COUNTER - Unable to request IRQ. Aborting.\n");
    free_irq(IRQ,NULL);
    return -EINVAL;
  }

  return 0;
}

/**
* Module exit function
*/
static void __exit btnrpi_exit(void)
{
  printk(KERN_INFO "COUNTER - Unloading driver\n");
  setdown();
  free_irq(IRQ, NULL);
}

MODULE_LICENSE("GPLv3");
MODULE_DESCRIPTION("Linux LED driver");
MODULE_AUTHOR("Viktor Enfeldt, Björn Blomberg");

module_init(btnrpi_init);
module_exit(btnrpi_exit);
