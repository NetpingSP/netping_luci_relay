

local util = require "luci.util"

--require "luci.fad.classes.inputtype"
local Variable = require 'luci.fad.classes.variable'

--require 'luci.fad.classes.1'


local memo = Variable:new('relay[1].memo')

util.perror("MEMO ==")
util.perror(memo.value)

util.perror("ALL MODIFIERS OF MEMO ==")
util.dumptable(memo.modifiers)


local address = Variable:new('relay[1].proto.snmp[1].address')

util.perror("SNMP ADDRESS ==")
util.perror(address.value)

util.perror("ALL MODIFIERS OF SNMP ADDRESS ==")
util.dumptable(address.modifiers)


