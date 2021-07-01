

local util = require "luci.util"
local log = require "luci.fad.utils.log"

--require "luci.fad.classes.inputtype"
local Variable = require 'luci.fad.classes.variable'

local Relay = require 'luci.fad.classes.relay'


local memo = Variable:load('relay[1].memo')

--[[
util.perror("MEMO ==")
util.perror(memo.value)

util.perror("ALL MODIFIERS OF MEMO ==")
util.dumptable(memo.modifiers)


local address = Variable:load('relay[1].proto.snmp[1].address')

util.perror("SNMP ADDRESS ==")
util.perror(address.value)

util.perror("ALL MODIFIERS OF SNMP ADDRESS ==")
util.dumptable(address.modifiers)

]]



local r1 = Relay:load('relay[1]')

--util.perror("=========== RELAY MEMO ==")
--util.perror(r1.memo.name)
--util.perror(r1.memo.value)

--util.perror("====== RELAY ==")
--util.dumptable(r1)

--local showin = 'widget.modal.setting.relay'
--util.perror("\n\n\n\n====== RELAY PRESENTED in " .. showin)
--util.dumptable(r1:presentedParams(showin))

--local ar = Relay:list()

--log("ALL RELAYS", ar)
