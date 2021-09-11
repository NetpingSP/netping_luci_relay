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
uci_config_snmp = "netping_luci_relay_adapter_snmp"

def ubus_init():
    def get_state_callback(event, data):
        ret_val = {}
        sect = data['section']
        try:
            relay_dict = curr_relays[sect]
        except KeyError:
            return

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
        try:
            relay_dict = curr_relays[sect]
        except KeyError:
            return

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

def check_param_relay(param):
    try:
        address = param['address']
        port = param['port']
        oid = param['oid']
        period = param['period']
        community = param['community']
        timeout = param['timeout']
    except KeyError:
        return False

    return True

def parseconfig():
    curr_relays.clear()
    try:
        confvalues = ubus.call("uci", "get", {"config": "netping_luci_relay"})
    except RuntimeError:
        logger.error("RuntimeError: uci get netping_luci_relay")
        sys.exit(-1)

    for confdict in list(confvalues[0]['values'].values()):
        if confdict['.type'] == "relay":
            if confdict['proto'] == uci_config_snmp:
                try:
                    conf_proto = ubus.call("uci", "get", {"config": uci_config_snmp})
                except RuntimeError:
                    logger.error("RuntimeError: uci get {0}".format(uci_config_snmp))
                    sys.exit(-1)

                for protodict in list(conf_proto[0]['values'].values()):
                    if not check_param_relay(protodict):
                        continue

                    if protodict['.name'] == confdict['.name']:
                        protodict['status'] = confdict['status']
                        protodict['state'] = confdict['state']
                        curr_relays[protodict['.name']] = protodict

def reparseconfig(event, data):
    if data['config'] == uci_config_snmp:
        try:
            conf_proto = ubus.call("uci", "get", {"config": uci_config_snmp})
        except RuntimeError:
            logger.error("RuntimeError: uci get {0}".format(uci_config_snmp))
            for relay, config in curr_relays.items():
                th = config['thread']
                if th.is_alive():
                    th.stop()
            sys.exit(-1)

        # Add & edit relay
        for protodict in list(conf_proto[0]['values'].values()):
            if not check_param_relay(protodict):
                continue

            config = curr_relays.get(protodict['.name'])
            if config is None:
                # Add new relay
                protodict['status'] = '0'
                protodict['state'] = '0'

            else:
                # Edit relay
                th = config['thread']
                if th.is_alive():
                    if th.checkthread(protodict['address'], protodict['port'], protodict['oid'],
                                      protodict['period'], protodict['community'], protodict['timeout']):
                        continue
                    else:
                        th.stop()
                        th.join()

            # Run polling thread on SNMP
            snmpthread = SNMPThread(protodict['.name'], protodict['address'], protodict['port'], protodict['oid'],
                                    protodict['period'], protodict['community'], protodict['timeout'])
            snmpthread.start()
            protodict['thread'] = snmpthread
            curr_relays[protodict['.name']] = protodict

        # Deleting relay
        relays = list(curr_relays.keys())
        for relay in relays:
            relay_exists = False
            for protodict in list(conf_proto[0]['values'].values()):
                if protodict['.name'] == relay:
                    relay_exists = True
                    break

            if relay_exists == False:
                config = curr_relays.get(relay)
                th = config['thread']
                if th.is_alive():
                    th.stop()
                del curr_relays[relay]

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

    def checkthread(self, address, port, oid, period, community, timeout):
        if address == self.address and int(port) == self.port and oid == self.oid and float(period) == self.period and \
                community == self.community and float(timeout) == self.timeout:
            return True
        else:
            return False

    def run(self):
        snmpget = cmdgen.CommandGenerator()
        while not self._stoped:
            config_relay = curr_relays[self.ID]
            try:
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

    relays = list(curr_relays.keys())
    for relay in relays:
        config = curr_relays.get(relay)
        if not check_param_relay(config):
            del curr_relays[relay]
            continue

        snmpthread = SNMPThread(config['.name'], config['address'], config['port'], config['oid'],
                                config['period'], config['community'], config['timeout'])
        snmpthread.start()
        config['thread'] = snmpthread

    ubus.listen(("commit", reparseconfig))

    try:
        while True:
            ubus.loop(1)
    except KeyboardInterrupt:
        print("__main__ === KeyboardInterrupt")
        for relay, config in curr_relays.items():
            th = config['thread']
            if th.is_alive():
                th.stop()

    ubus.disconnect()
