# netping_luci_relay

OpenWrt LuCI page for relay management.

![me](https://github.com/Netping/netping_luci_relay/blob/v4/control/screenshot_animated.gif)

## Структура файлов

```bash
├── control
├── dev
│   └── commits_comments
├── etc
│   ├── config
│   └── netping_relay
│       └── template
│           ├── custom
│           └── default
├── luasrc
│   ├── controller
│   │   └── netping_luci_relay
│   ├── model
│   │   └── cbi
│   │       └── netping_luci_relay
│   └── view
│       └── netping_luci_relay
│           ├── ui_overrides
│           ├── ui_utils
│           └── ui_widgets
└── www
    └── luci-static
        └── resources
            └── netping
                ├── datepicker
                │   └── css
                ├── fonts
                │   └── variable_fonts
                ├── icons
                ├── jquery
                ├── rslider
                └── utils

```

## Инструкция по установке

1. Скопировать файлы из папки **/luasrc** в соответствующие подпапки устройства **/usr/lib/lua/luci**
2. Скопировать файлы из /www в соответствующие подпапки устройства **/www**

## ToDo

1. DONE: Если пользователь переключает Weekly, Monthly, Yearly не выбрав предварительно ни одной даты, то установить сегодняшнюю дату
2. Сделать "плавающую" ширину виджета Slider, т.к. при уменьшении экрана (уже при 1000 px) элементы наехжают друг на друга.
