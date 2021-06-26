--[[
Modifier proto class
]]
-- local util = require "../../util.lua"
-- module("Modifier", package.seeall)

local util = require "luci.util"

local Modifier = {}
Modifier.config = 'netping_relay_variables'
function Modifier:new()
	local obj = {}
	obj.variable = ''
	obj.label = ''
	obj.oldbrother = 0
	obj.visibility = ''

	setmetatable(obj, self)
	self.__index = self; return obj;
end

return Modifier