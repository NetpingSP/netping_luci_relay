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
        state = ubus.call("uci", "get", {"config":"netping_luci_relay","section":sect,"option":"state"})
        name = ubus.call("uci", "get", {"config":"netping_luci_relay","section":sect,"option":"name"})
        logger.debug('state = %s', state)
        logger.debug('name = %s', name)
        val_state = state[0]['value']
        val_name = name[0]['value']
        print('Button pressed for "%s"' % val_name)
        ret_val = {}
        ret_val["state"] = int(val_state)
        event.reply(ret_val)

    def set_state_callback(event, data):
        sect = data['section']
        state = data['state']
        logger.debug('CALL set_state (%s) state=%s', sect, state)
        ubus.call("uci", "set", {"config":"netping_luci_relay","section":sect,"values":{"state":state}})
        ubus.call("uci", "commit", {"config":"netping_luci_relay"})

    def get_status_callback(event, data):
        sect = data['section']
        logger.debug('CALL get_status (%s)', sect)
        status = ubus.call("uci", "get", {"config":"netping_luci_relay","section":sect,"option":"status"})
        logger.debug('status= %s', status)
        val_status = status[0]['value']
        ret_val = {}
        ret_val["status"] = int(val_status)
        event.reply(ret_val)

    ubus.add(
        'netping_relay', {
            'get_state': {
                'method': get_state_callback,
                'signature': {
                    'section': ubus.BLOBMSG_TYPE_STRING,
                }
            },
            'set_state': {
                'method': set_state_callback,
                'signature': {
                    'section': ubus.BLOBMSG_TYPE_STRING,
                    'state': ubus.BLOBMSG_TYPE_STRING
                }
            },
            'get_status': {
                'method': get_status_callback,
                'signature': {
                    'section': ubus.BLOBMSG_TYPE_STRING,
                }
            }
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

