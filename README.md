# netping_luci_relay

OpenWrt LuCI page for relay management.

![me](https://github.com/Netping/netping_luci_relay/blob/v4/control/screenshot_animated.gif)

## Структура файлов

Данный модуль, начиная с ветки v5, приведён в соответствие с [Web интерфейс - структура файлов - рекомендации](https://netping.atlassian.net/wiki/spaces/PROJ/pages/2728821288/Web+-+LuCI)

```bash
.
├── control
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
└── root
    ├── etc
    │   ├── config
    │   └── netping_luci_relay
    │       └── template
    │           └── default
    ├── usr
    │   └── lib
    │       └── lua
    │           ├── netping
    │           └── websocket
    └── www
        └── luci-static
            └── resources
                └── netping
                    ├── datepicker
                    ├── fonts
                    ├── icons
                    ├── jquery
                    ├── rslider
                    └── utils
```

## Инструкция по установке ВАРИАНТ №1

1. Взять готовый IPK-файл со страницы [релизов](https://github.com/Netping/netping_luci_relay/releases)
2. Если необходимо скомпилировать под другую архитектуру, то подготовить IPK-файл, воспользовавшись данной методикой: [Выпуск версии модуля LuCI в виде .ipk файла](https://netping.atlassian.net/wiki/spaces/PROJ/pages/3194945556/LuCI+.ipk)
3. Скопировать на устройство и установить командой:
opkg update && opkg install netping_luci_relay_0.0.1-1_all.ipk --force-reinstall

## Инструкция по установке ВАРИАНТ №2

1. Скопировать файлы из папки **/luasrc** в соответствующие подпапки устройства **/usr/lib/lua/luci**
2. Скопировать файлы из /root в соответствующие подпапки устройства
3. Установить дополнительные пакеты при помощи следующих команд:
* opkg update
* opkg install luci-compat lua-ev luasocket luabitop

## Инструкция по тестирование Websocket

Вебсокет настроен на порт 8082. Чтобы отредактировать порт отредактируйте файлы:
* /usr/lib/lua/luci/netping/websocket_relay.lua
* /usr/lib/lua/luci/view/netping_luci_relay/relay_websocket.js.htm

![me](https://github.com/Netping/netping_luci_relay/blob/v5/wsport_lua.png)
![me](https://github.com/Netping/netping_luci_relay/blob/v5/wsport_js.png)

1. git clone https://github.com/Netping/netping_luci_relay.git
2. cd ./netping_luci_relay
3. make install
4. ssh openwrt
5. $ lua /usr/lib/lua/luci/netping/websocket_relay.lua
6. Open browser URL: http://192.168.0.24/cgi-bin/luci/admin/system/relay
7. Play with "state" of relay using the command:
```$ uci set netping_luci_relay.cfg042442.state=1```

[Screencast](https://www.youtube.com/watch?v=FQKr_YZB6S0)

## ToDo

1. DONE: ~~Если пользователь переключает Weekly, Monthly, Yearly не выбрав предварительно ни одной даты, то установить сегодняшнюю дату.~~
2. DONE: ~~Сделать "плавающую" ширину виджета Slider, т.к. при уменьшении экрана (уже при 1000 px) элементы наезжают друг на друга.~~
3. XHR() is deprecated. Use L.request instead. See TODO in /usr/lib/lua/luci/view/netping_luci_relay/relay.js.htm
4. Websocket - finalize code
