# SHELL := /bin/bash

VM ?= openwrt.vm
DST ?= /root/netping_luci_relay/

install:
	@echo "== Install netping_luci_relay"
	@cp -fR luasrc/* /usr/lib/lua/
	@cp -fR www/* /www/
	@cp -fR root/etc/* /etc/
	@/etc/init.d/uhttpd restart

deploy:
	@echo "== Deploy project to VM"
	@rsync -avP . $(VM):$(DST) > /dev/null
	@ssh $(VM) "cd $(DST) && make install"
