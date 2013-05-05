$ set verify
$ libdir = "[--.build.VMS-" + "''f$getsyi("ARCH_NAME")'" + "]"
$
$ if f$search("*.obj") .nes. ""
$ then
$    delete/nolog/noconfirm *.obj;*
$ endif
$
$! Note: must link/threads when using async
$
$ cc/nolist/names=(as_is,shortened)/include=[-] MQTTAsync_publish.c
$ link/threads MQTTAsync_publish.obj,'libdir'mqttv3a.olb/lib
$
$ cc/nolist/names=(as_is,shortened)/include=[-] MQTTAsync_subscribe.c
$ link/threads MQTTAsync_subscribe.obj,'libdir'mqttv3a.olb/lib
$
$ cc/nolist/names=(as_is,shortened)/include=[-] pubasync.c
$ link/threads pubasync.obj,'libdir'mqttv3c.olb/lib
$
$ cc/nolist/names=(as_is,shortened)/include=[-] pubsync.c
$ link/threads pubsync.obj,'libdir'mqttv3c.olb/lib
$
$ cc/nolist/names=(as_is,shortened)/include=[-] stdinpub.c
$ link/threads stdinpub.obj,'libdir'mqttv3c.olb/lib
$
$ cc/nolist/names=(as_is,shortened)/include=[-] stdoutsub.c
$ link/threads stdoutsub.obj,'libdir'mqttv3c.olb/lib
$
$ cc/nolist/names=(as_is,shortened)/include=[-] stdoutsuba.c
$ link/threads stdoutsuba.obj,'libdir'mqttv3a.olb/lib
$
$ cc/nolist/names=(as_is,shortened)/include=[-] subasync.c
$ link/threads subasync.obj,'libdir'mqttv3c.olb/lib
$
$ purge/log
$ exit

