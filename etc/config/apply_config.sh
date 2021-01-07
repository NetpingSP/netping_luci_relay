#!/bin/sh
# original example - from: https://github.com/yichya/luci-theme-openwrt-custom/blob/master/root/etc/uci-defaults/30_luci-theme-openwrt
if [ "$PKG_UPGRADE" != 1 ]; then
	uci batch <<-EOF
		set luci.themes.Netping=/luci-static/bootsrtap-netping
		set luci.main.mediaurlbase=/luci-static/bootsrtap-netping
		commit luci
	EOF
fi

exit 0