sshpass -p 'root' rsync -avzzhe "ssh -p 22" --progress --recursive ../luasrc/ root@openwrt:/usr/lib/lua/luci/
sshpass -p 'root' rsync -avzzhe "ssh -p 22" --progress --recursive ../root/ root@openwrt:/
sshpass -p 'root' rsync -avzzhe "ssh -p 22" --progress --recursive ../adapter/luasrc/ root@openwrt:/usr/lib/lua/luci/
sshpass -p 'root' rsync -avzzhe "ssh -p 22" --progress --recursive ../adapter/root/ root@openwrt:/