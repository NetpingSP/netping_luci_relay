# netping_luci_relay

OpenWrt LuCI page for relay management.

## Структура файлов

Структура файлов формируется в соответствие с [Web интерфейс - структура файлов - рекомендации](https://netping.atlassian.net/wiki/spaces/PROJ/pages/2728821288/Web+-+LuCI)

Начиная с версии 0.0.3 имеется возможность расширения данной функциональности за счёт адаптеров протокола. Типовой код адаптера и инструкции даны в отдельном репозитарии: [Netping HTTP adapter](https://github.com/antoncom/netping_luci_relay_adapter_http)

```bash
.
├── control
│   ├── v.0.0.1
│   └── v.0.0.4
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

Скопировать файлы на устройство, разложив их по соответствующим директориям

## How to add new adapter

[Screencast](https://youtu.be/Qj2uZqPfCm4)


## How to add new parameters to SNMP adapter in the LuCI interface

1. Update config file
2. Update View file
3. Create validator

[Screencast](https://www.youtube.com/watch?v=zvEhOXexVfM)
