/*
 * Sample kobject implementation
 *
 * Copyright (C) 2004-2007 Greg Kroah-Hartman <greg@kroah.com>
 * Copyright (C) 2007 Novell Inc.
 *
 * Released under the GPL version 2 only.
 *
 */
#include <linux/kobject.h>
#include <linux/string.h>
#include <linux/sysfs.h>
#include <linux/module.h>
#include <linux/init.h>
#include "pvs_speed_control.h"

/*
 * The "pvs_speed" file where a static variable is read from and written to.
 */
static ssize_t pvs_speed_show(struct kobject *kobj, struct kobj_attribute *attr,
			char *buf)
{

#ifdef CONFIG_CPU_OC
#ifdef CONFIG_CPU_OC_ULTIMATE
     pvs_speed = 3;
#else
     pvs_speed = 1;
#endif
#else
    pvs_speed = 2;
#endif
	return sprintf(buf, "%d\n", pvs_speed);
}

static ssize_t pvs_speed_store(struct kobject *kobj, struct kobj_attribute *attr,
			 const char *buf, size_t count)
{
	int var = get_pvs_speed_to_set();

	sscanf(buf, "%du", &var);
	
	if (var == 0)
	    pvs_speed = var;
	else if (var == 1)
	    pvs_speed = var;
	else if (var == 2)
	    pvs_speed = var;
	else if (var == 3)
	    pvs_speed = var;
	    
	return count;
}

static struct kobj_attribute pvs_speed_attribute =
	__ATTR(pvs_speed, 0666, pvs_speed_show, pvs_speed_store);


/*
 * Create a group of attributes so that we can create and destroy them all
 * at once.
 */
static struct attribute *attrs[] = {
	&pvs_speed_attribute.attr,
	NULL,	/* need to NULL terminate the list of attributes */
};

/*
 * An unnamed attribute group will put all of the attributes directly in
 * the kobject directory.  If we specify a name, a subdirectory will be
 * created for the attributes with the directory being the name of the
 * attribute group.
 */
static struct attribute_group attr_group = {
	.attrs = attrs,
};

static struct kobject *example_kobj;

static int __init example_init(void)
{
	int retval;

	/*
	 * Create a simple kobject with the name of "kobject_example",
	 * located under /sys/kernel/
	 *
	 * As this is a simple directory, no uevent will be sent to
	 * userspace.  That is why this function should not be used for
	 * any type of dynamic kobjects, where the name and number are
	 * not known ahead of time.
	 */
	example_kobj = kobject_create_and_add("pvs_speed_control", kernel_kobj);
	if (!example_kobj)
		return -ENOMEM;

	/* Create the files associated with this kobject */
	retval = sysfs_create_group(example_kobj, &attr_group);
	if (retval)
		kobject_put(example_kobj);

	return retval;
}

static void __exit example_exit(void)
{
	kobject_put(example_kobj);
}

module_init(example_init);
module_exit(example_exit);
MODULE_LICENSE("GPLv2");
MODULE_AUTHOR("Louis Teboul <admin@androguide.fr>");
