#!/usr/bin/env python3

import sys
import logging
import random
from pysnmp.entity.rfc3413.oneliner import cmdgen
from pysnmp.proto import rfc1902
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileModifiedEvent
import time

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
        ret_val["state"] = random.randint(0,1)
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
        ret_val["status"] = random.randint(0,2)
        event.reply(ret_val)

    def set_status_callback(event, data):
        sect = data['section']
        status = data['status']
        logger.debug('CALL set_status (%s) status=%s', sect, status)
        ubus.call("uci", "set", {"config":"netping_luci_relay","section":sect,"values":{"status":status}})
        ubus.call("uci", "commit", {"config":"netping_luci_relay"})

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
            },
            'set_status': {
                'method': set_status_callback,
                'signature': {
                    'section': ubus.BLOBMSG_TYPE_STRING,
                    'status': ubus.BLOBMSG_TYPE_STRING
                }
            }
        }
    )

class Handler(FileSystemEventHandler):
    def on_modified(self, event):
        if type(event) == FileModifiedEvent:
            print("File modified!!!")
            print(event.src_path)

if __name__ == '__main__':

    observer = Observer()
    observer.schedule(Handler(), path='/etc/config/netping_luci_relay_adapter_snmp', recursive=False)
    observer.start()

    try:
        while True:
            time.sleep(0.1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

    exit(0)

    snmpget = cmdgen.CommandGenerator()
    try:
        errorIndication, errorStatus, errorIndex, varBinds = snmpget.getCmd(
            cmdgen.CommunityData('SWITCH', mpModel=0),
            cmdgen.UdpTransportTarget(('125.227.188.172', 31132), timeout=5, retries=0),
            ".1.3.6.1.4.1.25728.5500.5.1.2.1"
        )
        if errorIndication:
            print("STOP WITH ERROR: {}".format(errorIndication))
        elif errorStatus:
            print("STOP with {0} at {1}".format(errorStatus.prettyPrint(),
                                                errorIndex and varBinds[int(errorIndex) - 1][0] or '?'))
        else:
            result = ''
            for varBind in varBinds:
                result += str(varBind)
            print("getCmd ", result)
#        time.sleep(self.period)
    except (OSError, RuntimeError) as e:
        print("STOP WITH ERROR: {}".format(e))

    try:
        errorIndication, errorStatus, errorIndex, varBinds = snmpget.setCmd(
            cmdgen.CommunityData('SWITCH', mpModel=0),
            cmdgen.UdpTransportTarget(('125.227.188.172', 31132), timeout=5, retries=0),
            ('.1.3.6.1.4.1.25728.5500.5.1.2.1', rfc1902.Integer(0))
        )
        if errorIndication:
            print("STOP WITH ERROR: {}".format(errorIndication))
        elif errorStatus:
            print("STOP with {0} at {1}".format(errorStatus.prettyPrint(),
                                                errorIndex and varBinds[int(errorIndex) - 1][0] or '?'))
        else:
            result = ''
            for varBind in varBinds:
                result += str(varBind)
            print("setCmd ", result)
    #        time.sleep(self.period)
    except (OSError, RuntimeError) as e:
        print("STOP WITH ERROR: {}".format(e))


    exit(0)




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

