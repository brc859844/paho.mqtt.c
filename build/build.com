$ set verify
$ dir = "VMS-" + "''f$getsyi("ARCH_NAME")'"
$ tmp = "''dir'" + ".dir"
$
$ if f$search(''tmp') .eqs. ""
$ then
$    write sys$output "Creating directory ''tmp'"
$    create/dir [.'dir']
$ endif
$
$! Note that the SSL builds require a later version of SSL than that provided
$! by HP...
$!
$! ... so we use http://www.polarhome.com/openssl/files/openssl-101c.zip
$!
$
$ if f$search("*.obj") .nes. ""
$ then
$    delete/nolog/noconfirm *.obj;*
$ endif
$
$
$! Synchronous/blocking
$!
$ cc/nolist/names=(as_is,shortened) [-.src]Clients.c
$ cc/nolist/names=(as_is,shortened) [-.src]Heap.c
$ cc/nolist/names=(as_is,shortened) [-.src]LinkedList.c
$ cc/nolist/names=(as_is,shortened) [-.src]Log.c
$ cc/nolist/names=(as_is,shortened) [-.src]Messages.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTClient.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTPacket.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTPacketOut.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTPersistence.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTPersistenceDefault.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTProtocolClient.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTProtocolOut.c
$ cc/nolist/names=(as_is,shortened) [-.src]SocketBuffer.c
$ cc/nolist/names=(as_is,shortened) [-.src]Socket.c
$ cc/nolist/names=(as_is,shortened) [-.src]StackTrace.c
$ cc/nolist/names=(as_is,shortened) [-.src]Thread.c
$ cc/nolist/names=(as_is,shortened) [-.src]Tree.c
$ cc/nolist/names=(as_is,shortened) [-.src]utf-8.c
$
$ call mklib 'dir' "mqttv3c.olb" "mqttv3c$shr.exe" "sync.opt" ""
$
$! Asynchronous
$!
$ cc/nolist/names=(as_is,shortened) [-.src]Clients.c
$ cc/nolist/names=(as_is,shortened) [-.src]Heap.c
$ cc/nolist/names=(as_is,shortened) [-.src]LinkedList.c
$ cc/nolist/names=(as_is,shortened) [-.src]Log.c
$ cc/nolist/names=(as_is,shortened) [-.src]Messages.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTAsync.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTPacket.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTPacketOut.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTPersistence.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTPersistenceDefault.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTProtocolClient.c
$ cc/nolist/names=(as_is,shortened) [-.src]MQTTProtocolOut.c
$ cc/nolist/names=(as_is,shortened) [-.src]SocketBuffer.c
$ cc/nolist/names=(as_is,shortened) [-.src]Socket.c
$ cc/nolist/names=(as_is,shortened) [-.src]StackTrace.c
$ cc/nolist/names=(as_is,shortened) [-.src]Thread.c
$ cc/nolist/names=(as_is,shortened) [-.src]Tree.c
$ cc/nolist/names=(as_is,shortened) [-.src]utf-8.c
$
$ call mklib 'dir' "mqttv3a.olb" "mqttv3a$shr.exe" "async.opt" ""
$
$
$! Synchronous/blocking, SSL
$!
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Clients.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Heap.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]LinkedList.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Log.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Messages.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTClient.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTPacket.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTPacketOut.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTPersistence.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTPersistenceDefault.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTProtocolClient.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTProtocolOut.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]SocketBuffer.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Socket.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]SSLSocket.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]StackTrace.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Thread.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Tree.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]utf-8.c
$
$ call mklib 'dir' "mqttv3cs.olb" "mqttv3cs$shr.exe" "sync.opt" "ssl.opt"
$
$
$! Asynchronous, SSL
$!
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Clients.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Heap.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]LinkedList.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Log.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Messages.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTAsync.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTPacket.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTPacketOut.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTPersistence.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTPersistenceDefault.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTProtocolClient.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]MQTTProtocolOut.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]SocketBuffer.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Socket.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]SSLSocket.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]StackTrace.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Thread.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]Tree.c
$ cc/nolist/names=(as_is,shortened)/define=(OPENSSL) [-.src]utf-8.c
$
$ call mklib 'dir' "mqttv3as.olb" "mqttv3as$shr.exe" "async.opt" "ssl.opt"
$
$ delete/nolog/noconfirm [.cxx_repository]*.*;*
$ delete/nolog/noconfirm cxx_repository.dir;
$
$ exit
$
$
$ mklib: subroutine
$    olb = "[.''p1']''p2'"
$    library/create 'olb'
$    purge/log 'olb'
$    library/insert/log 'olb' *.obj
$    delete/log/noconfirm *.obj;*
$
$    if p5 .nes. ""
$    then
$       link/share=[.'p1']'p3' 'olb'/lib,[]'p4'/opt,[]'p5'/opt
$    else
$       link/share=[.'p1']'p3' 'olb'/lib,[]'p4'/opt
$    endif
$    purge/log [.'p1']'p3'
$    exit
$ endsubroutine
