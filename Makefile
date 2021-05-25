
include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI NetPing Relay
LUCI_DEPENDS:=+luci-compat +lua-ev +luasocket +luabitop
LUCI_DESCRIPTION:=Relay management
LUCI_PKGARCH:=all

PKG_VERSION:=0.0.1
PKG_LICENSE:=GPL-3.0-or-later

include /home/anton/lua_projects/DKSF708/MAKING_A_PACKAGE/openwrt-sdk-19.07.7-x86-64_gcc-7.5.0_musl.Linux-x86_64/feeds/luci/luci.mk
# include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature