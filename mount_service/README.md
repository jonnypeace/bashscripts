All files here are for the host server set up. 

Some configs, 1 service and a couple of my scripts to keep my NFS shares ticking over with rsync backups.

I used a service to mount the drives because i'm not a fan of a headless system hanging on boot, with the auto option in fstab.
Also crontab works fine, but I found mail clutter (i know that can be turned off) and it only needs run at boot.

DO NOT copy over your own configs with these configs, these are just examples.

Each file will need some modifications to suit your set up.. usernames, directories, drive names, /dev/sda etc.

Each file has some help inside them, if more info required, feel free to message me (jonny) at royalpython2@hotmail.com

Hopefully helpful for those like me.

If you follow along for the most part, you can get some smart health and success information from systemctl

~~~
sudo systemctl status mount_3tb.service --lines=17
~~~

Note: it will say inactive dead, because it only runs at boot.
~~~
jonny@server:~ $ sudo systemctl status mount_3tb.service --lines=17
● mount_3tb.service - Mount 3tb drives
     Loaded: loaded (/etc/systemd/system/mount_3tb.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Thu 2022-03-03 11:39:15 GMT; 46min ago
    Process: 2146 ExecStart=/bin/sh -c /home/jonny/mountNFS.sh (code=exited, status=0/SUCCESS)
   Main PID: 2146 (code=exited, status=0/SUCCESS)
        CPU: 584ms

Mar 03 11:39:14 pi4ipserver systemd[1]: Starting Mount 3tb drives...
Mar 03 11:39:14 pi4ipserver sudo[2149]:    jonny : PWD=/ ; USER=root ; COMMAND=/usr/sbin/smartctl -H /dev/sda
Mar 03 11:39:14 pi4ipserver sudo[2149]: pam_unix(sudo:session): session opened for user root(uid=0) by (uid=1000)
Mar 03 11:39:14 pi4ipserver sudo[2149]: pam_unix(sudo:session): session closed for user root
Mar 03 11:39:14 pi4ipserver sudo[2153]:    jonny : PWD=/ ; USER=root ; COMMAND=/usr/sbin/smartctl -A /dev/sda
Mar 03 11:39:14 pi4ipserver sudo[2153]: pam_unix(sudo:session): session opened for user root(uid=0) by (uid=1000)
Mar 03 11:39:14 pi4ipserver sudo[2153]: pam_unix(sudo:session): session closed for user root
Mar 03 11:39:14 pi4ipserver sh[2147]: pi 3tb1 drive mounted & overall-health: PASSED & Reallocated_Event_Count: 0 Current_Pending_Sector: 0 Offline_Uncorrectable: 0
Mar 03 11:39:14 pi4ipserver sudo[2165]:    jonny : PWD=/ ; USER=root ; COMMAND=/usr/sbin/smartctl -H /dev/sdb
Mar 03 11:39:14 pi4ipserver sudo[2165]: pam_unix(sudo:session): session opened for user root(uid=0) by (uid=1000)
Mar 03 11:39:14 pi4ipserver sudo[2165]: pam_unix(sudo:session): session closed for user root
Mar 03 11:39:14 pi4ipserver sudo[2170]:    jonny : PWD=/ ; USER=root ; COMMAND=/usr/sbin/smartctl -A /dev/sdb
Mar 03 11:39:14 pi4ipserver sudo[2170]: pam_unix(sudo:session): session opened for user root(uid=0) by (uid=1000)
Mar 03 11:39:15 pi4ipserver sudo[2170]: pam_unix(sudo:session): session closed for user root
Mar 03 11:39:15 pi4ipserver sh[2147]: pi 3tb2 drive mounted & overall-health: PASSED & Reallocated_Event_Count: 0 Current_Pending_Sector: 0 Offline_Uncorrectable: 0
Mar 03 11:39:15 pi4ipserver systemd[1]: mount_3tb.service: Succeeded.
Mar 03 11:39:15 pi4ipserver systemd[1]: Finished Mount 3tb drives.
~~~
