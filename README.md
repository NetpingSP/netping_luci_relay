# netping_luci_relay

OpenWrt LuCI page for relay management.

![me](https://github.com/Netping/netping_luci_relay/blob/v3/control/screenshot_animated.gif)

## Структура файлов

```bash
├── control
│   ├── conffiles
│   ├── control
│   └── screenshot_animated.gif
├── dev
│   ├── commits_comments
│   │   └── 202010280237.txt
│   ├── openwrt-19.07.4-x86-generic-combined-ext4.img.vdi
│   └── readme.txt
├── etc
│   └── config
│       ├── settings
│       └── settings_v1
├── luasrc
│   ├── controller
│   │   └── netping_luci_relay
│   │       └── index.lua
│   ├── model
│   │   └── cbi
│   │       └── netping_luci_relay
│   │           ├── alert.lua
│   │           └── relay.lua
│   └── view
│       └── netping_luci_relay
│           ├── css.htm
│           ├── get_cursor_position.htm
│           ├── jquery.highlight-within-textarea.css.htm
│           ├── js.htm
│           ├── modal_alert.htm
│           ├── modal.htm
│           ├── relay_alert_list.htm
│           ├── table.htm
│           └── textAreaHighlighted.htm
├── README.md
└── www
    └── luci-static
        └── resources
            ├── icons
            │   ├── check-grey.png
            │   └── check.png
            ├── jquery-3.5.1.min.js
            └── jquery.highlight-within-textarea.js
```

## Инструкция по установке

1. Скопировать файлы из папки **/luasrc** в соответствующие подпапки устройства **/usr/lib/lua/luci**
2. Скопировать файлы из /www в соответствующие подпапки устройства **/www**

## ToDo

1. Интерактивную часть добавления/удаления условий
2. Back-End
