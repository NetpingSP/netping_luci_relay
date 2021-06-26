--[[
InputType class
]]
local util = require "luci.util"

local Modifier = require 'luci.fad.classes.modifier'

local InputType = {}
function InputType:new(type)
	local obj = Modifier:new()
	obj.type = type

	function obj:render(type)
		local widget = ''
		if (type == "string") then
			widget = [[ var memo = new ui.Textfield("]] .. obj.type .. [[", {
							datatype: "rangelength(4,128)",
							validate: grammaValidator(window.<%=gramma.value %>, "<%=errormsg.value %>")
					});]]
		end
		return widget
	end


	setmetatable(obj, self)
	self.__index = self; return obj;
end


