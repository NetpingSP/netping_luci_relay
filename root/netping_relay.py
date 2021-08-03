#!/usr/bin/env python3

import sys
import logging

logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger('netping_relay')

try:
    import ubus
except ImportError:
    logger.error('Failed import ubus.')
    sys.exit(-1)

def ubus_init():
    def get_state_callback(event, data):
        sect = data['section']
        logger.debug('CALL get_state (%s)', sect)
        res = ubus.call("uci", "get", {"config":"netping_luci_relay","section":sect,"option":"state"})
        name = ubus.call("uci", "get", {"config":"netping_luci_relay","section":sect,"option":"name"})
        logger.debug('res = %s', res)
        logger.debug('name = %s', name)
        val_res = res[0]['value']
        val_name = name[0]['value']
        print('Button pressed for "%s"' % val_name)

    ubus.add(
        'netping_relay', {
            'get_state': {
                'method': get_state_callback,
                'signature': {
                    'section': ubus.BLOBMSG_TYPE_STRING,
                }
            },
        }
    )


if __name__ == '__main__':

    if not ubus.connect("/var/run/ubus.sock"):
        sys.stderr.write('Failed connect to ubus\n')
        sys.exit(-1)

    ubus_init()

    try:
        while True:
            ubus.loop(1)
    except KeyboardInterrupt:
        print("__main__ === KeyboardInterrupt")

    ubus.disconnect()

