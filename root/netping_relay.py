#!/usr/bin/env python3

import sys
import logging
from pysnmp.entity.rfc3413.oneliner import cmdgen
from pysnmp.proto import rfc1902
import threading
import time

logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger('netping_relay')

try:
    import ubus
except ImportError:
    logger.error('Failed import ubus.')
    sys.exit(-1)

curr_relays = {}
status_norma = '0'
status_no_connection = '1'
status_error = '3'

def ubus_init():
    def get_state_callback(event, data):
        ret_val = {}
        sect = data['section']
        relay_dict = curr_relays[sect]
        logger.debug('CALL get_state (%s) = %s', sect, relay_dict['state'])
        ret_val["state"] = int(relay_dict['state'])
        event.reply(ret_val)

    def set_state_callback(event, data):
        sect = data['section']
        state = data['state']
        logger.debug('CALL set_state (%s) state=%s', sect, state)
        config_relay = curr_relays[sect]

        try:
            snmpget = cmdgen.CommandGenerator()
            errorIndication, errorStatus, errorIndex, varBinds = snmpget.setCmd(
                cmdgen.CommunityData(config_relay['community'], mpModel=0),
                cmdgen.UdpTransportTarget((config_relay['address'], int(config_relay['port'])),
                                          timeout=float(config_relay['timeout']), retries=0),
                (config_relay['oid'], rfc1902.Integer(int(state)))
            )
            if errorIndication:
                config_relay['status'] = status_no_connection
                logger.debug("errorIndication: {0} WITH ERROR: {1}".format(config_relay['.name'], errorIndication))
            elif errorStatus:
                config_relay['status'] = status_error
                logger.debug("errorStatus: {0} with {1} at {2}".format(config_relay['.name'], errorStatus.prettyPrint(),
                                                                       errorIndex and varBinds[int(errorIndex) - 1][0] or '?'))
            else:
                result = ''
                for varBind in varBinds:
                    result += str(varBind)
                config_relay['status'] = status_norma
        except (OSError, RuntimeError) as e:
            logger.debug("STOP {0} WITH ERROR: {1}".format(config_relay['.name'], e))

    def get_status_callback(event, data):
        ret_val = {}
        sect = data['section']
        relay_dict = curr_relays[sect]
        logger.debug('CALL get_status (%s) = %s', sect, relay_dict['status'])
        ret_val["status"] = int(relay_dict['status'])
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

class ReParseConfig(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)

    def reparseconfig(self, event, data):
        print("1235")
        print(type(data))
        print(data)

    def run(self):
        ubus.listen(("commit", self.reparseconfig))
        ubus.loop()

def parseconfig():
    curr_relays.clear()
    confvalues = ubus.call("uci", "get", {"config": "netping_luci_relay"})
    for confdict in list(confvalues[0]['values'].values()):
        if confdict['.type'] == "relay":
            if confdict['proto'] == "netping_luci_relay_adapter_snmp":
                conf_proto = ubus.call("uci", "get", {"config": confdict['proto']})
                for protodict in list(conf_proto[0]['values'].values()):
                    if protodict['.name'] == confdict['.name']:
                        protodict['status'] = confdict['status']
                        protodict['state'] = confdict['state']
                        curr_relays[protodict['.name']] = protodict

class SNMPThread(threading.Thread):
    def __init__(self, pollID, address, port, oid, period, community, timeout):
        threading.Thread.__init__(self)
        self.ID = pollID
        self.address = address
        self.port = int(port)
        self.period = float(period)
        self.oid = oid
        self.community = community
        self.timeout = float(timeout)
        self._stoped = False

    def stop(self):
        self._stoped = True

#    def checkthread(self, pollURL, oid, period, community, timeout):
#        if pollURL == self.url and oid == self.oid and float(period) == self.period and \
#                community == self.community and timeout == self.timeout:
#            return True
#        else:
#            return False

    def run(self):
        while not self._stoped:
            config_relay = curr_relays[self.ID]
            try:
                snmpget = cmdgen.CommandGenerator()
                errorIndication, errorStatus, errorIndex, varBinds = snmpget.getCmd(
                    cmdgen.CommunityData(self.community, mpModel=0),
                    cmdgen.UdpTransportTarget((self.address, self.port), timeout=self.timeout, retries=0),
                    self.oid
                )
                if errorIndication:
                    config_relay['status'] = status_no_connection
                    logger.debug("errorIndication: {0} WITH ERROR: {1}".format(self.ID, errorIndication))
                elif errorStatus:
                    config_relay['status'] = status_error
                    logger.debug("errorStatus: {0} with {1} at {2}".format(self.ID, errorStatus.prettyPrint(),
                                                            errorIndex and varBinds[int(errorIndex) - 1][0] or '?'))
                else:
                    result = ''
                    for varBind in varBinds:
                        result += str(varBind)
                    config_relay['state'] = result.split('= ')[1]
                    config_relay['status'] = status_norma
                time.sleep(self.period)
            except (OSError, RuntimeError) as e:
                logger.debug("STOP {0} WITH ERROR: {1}".format(self.ID, e))
                break

if __name__ == '__main__':

    if not ubus.connect("/var/run/ubus.sock"):
        sys.stderr.write('Failed connect to ubus\n')
        sys.exit(-1)

    ubus_init()
    parseconfig()

    for relay, config in curr_relays.items():
        snmpthread = SNMPThread(config['.name'], config['address'], config['port'], config['oid'],
                                config['period'], config['community'], config['timeout'])
        snmpthread.start()
        config['thread'] = snmpthread

    # Создание потока приема и обработки события изменения uci файла
    reparseconfig = ReParseConfig()
    reparseconfig.daemon = True
    reparseconfig.start()

    try:
        while True:
            ubus.loop(1)
    except KeyboardInterrupt:
        print("__main__ === KeyboardInterrupt")

    ubus.disconnect()
