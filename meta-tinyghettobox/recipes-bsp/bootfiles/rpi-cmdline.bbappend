
#CMDLINE_ROOT_PARTITION = "/dev/sda2"


CMDLINE:append = " fsck.mode=skip"
CMDLINE:append = " vt.global_cursor_default=0"
#CMDLINE:append = " quiet"
CMDLINE:append = " consoleblank=0"
#CMDLINE:append = " video=DSI-1:800x480M@30,rotate=180"
#CMDLINE:append = " printk.time=1 initcall_debug"
#CMDLINE:append = " earlycon"
#CMDLINE:append = " fbcon=map:1"
