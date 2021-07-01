local util = require "luci.util"

util.perror('============== 1 ==============')
local s = "relay.memo"
local t = {}

t = util.split(s, ".")

util.dumptable(t)

util.perror(t[#t-1])