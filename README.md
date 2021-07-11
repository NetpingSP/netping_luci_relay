# netping_luci_relay

OpenWrt LuCI page for relay management.

![me](https://github.com/Netping/netping_luci_relay/blob/v4/control/screenshot_animated.gif)

## Структура файлов

Структура файлов формируется в соответствие с [Web интерфейс - структура файлов - рекомендации](https://netping.atlassian.net/wiki/spaces/PROJ/pages/2728821288/Web+-+LuCI)

Начиная с версии 0.0.3 имеется возможность расширения данной функциональности за счёт адаптеров протокола. Типовой код адаптера и инструкции даны в отдельном репозитарии: [Netping HTTP adapter](https://github.com/antoncom/netping_luci_relay_adapter_http)

```bash
├── control
├── luasrc
│   ├── controller
│   │   └── netping_luci_relay
│   ├── model
│   │   ├── cbi
│   │   │   └── netping_luci_relay
│   │   └── netping
│   │       └── relay
│   │           └── adapter
│   └── view
│       └── netping_luci_relay
│           ├── ui_adapter
│           ├── ui_override
│           ├── ui_util
│           ├── ui_validator
│           └── ui_widget
└── root
    ├── etc
    │   ├── config
    │   └── netping_luci_relay
    │       └── template
    │           └── default
    ├── tmp
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
                    ├── nearley
                    ├── rslider
                    └── utils

```

## Инструкция по установке

1. Взять готовый IPK-файл со страницы [релизов](https://github.com/Netping/netping_luci_relay/releases)
2. Скопировать на устройство и установить командой:
opkg update && opkg install netping_luci_relay_0.0.1-1_all.ipk --force-reinstall

Примечание: Если необходимо скомпилировать под другую архитектуру, то подготовить IPK-файл, воспользовавшись данной методикой: [Выпуск версии модуля LuCI в виде .ipk файла](https://netping.atlassian.net/wiki/spaces/PROJ/pages/3194945556/LuCI+.ipk)

## Screencast demo

[Adapter installation from .ipk file](https://youtu.be/koNoIzhc9DE)

## ToDo

1. DONE: ~~Если пользователь переключает Weekly, Monthly, Yearly не выбрав предварительно ни одной даты, то установить сегодняшнюю дату.~~
2. DONE: ~~Сделать "плавающую" ширину виджета Slider, т.к. при уменьшении экрана (уже при 1000 px) элементы наезжают друг на друга.~~
3. XHR() is deprecated. Use L.request instead. See TODO in /usr/lib/lua/luci/view/netping_luci_relay/relay.js.htm
4. ~~Websocket - finalize code (NOT DONE AS IT'S ONLY ACTUAL FOR OLD VERSION: 0.0.1)~~
5. JSON-RPC requests for UBUS
6. Метод валидации Nearley позволят проверять промежуточные значения, водимые пользователем и выдаёт ошибку только если введён символ не соответствующей описанной грамматике. Но сейчас для быстроты интегарции это отключено, т.е. сообщение об ошибке выдаётся при вводе любого символа до тех пор пока значение поля не введено полностью.
