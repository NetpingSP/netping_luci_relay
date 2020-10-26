# netping_luci_relay

OpenWrt LuCI page for relay management.

![me](https://github.com/antoncom/netping_luci_relay/blob/main/control/relay-2020-10-23_23.27.41.gif)

## Структура файлов

```bash
├── control
│   ├── conffiles
│   └── control
├── dev
│   ├── openwrt-19.07.4-x86-generic-combined-ext4.img.vdi
│   └── readme.txt
├── etc
│   └── config
│       └── settings
└── luasrc
    ├── controller
    │   └── netping_luci_relay
    │       └── index.lua
    ├── model
    │   └── cbi
    │       └── netping_luci_relay
    │           └── relay.lua
    └── view
        └── netping_luci_relay
            ├── css.htm
            ├── js.htm
            └── table.htm
```

## Инструкция по установке

1. Скопировать файлы из папки **/luasrc** в соответствующие подпапки устройства **/usr/lib/lua/luci**
2. Очистить кэш при помощи команды 
```
rm -r /tmp/luci*
```
3. При дальнейшей разработке/модификации рекомендуется отключить кэширование командой
```
uci set luci.ccache='0'
```

## Благодарность

Код написан по примеру [luci-app-simple-adblock](https://github.com/openwrt/luci/tree/master/applications/luci-app-simple-adblock/)

## ToDo

1. Добавить поддержку i18n
2. Добавить наглядный спиннер, появляющийся при выполнении действия.
3. Добавить Toast (чтобы пользователь был информирован о происходящих действиях)
4. Современная кнопка-переключатель
