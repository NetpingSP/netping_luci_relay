#!/usr/bin/env lua

require "ubus"
require "uloop"
local util = require "luci.util"

--local inspect = require "inspect"

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
end

--[[
  A demo of ubus publisher binding. Should be run before subscriber.lua
--]]


uloop.init()

local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

local ubus_objects = {
	netping_relay = {
		list = {
			function(req, msg)
				for k, v in pairs(msg) do
					print("key=" .. k .. " value=" .. tostring(v))
					if (key == "adapter") then
						-- get and return list of adapters
					end
				end
			end, { type = ubus.STRING }
		},
		hello = {
			function(req, msg)
				conn:reply(req, {message="foo"});
				print("Call to function 'hello'")
				for k, v in pairs(msg) do
					print("key=" .. k .. " value=" .. tostring(v))
				end
			end, {id = ubus.INT32, msg = ubus.STRING }
		},
		hello1 = {
			function(req)
				conn:reply(req, {message="foo1"});
				conn:reply(req, {message="foo2"});
				print("Call to function 'hello1'")
			end, {id = ubus.INT32, msg = ubus.STRING }
		},
		__subscriber_cb = function( subs )
			print("total subs: ", subs )
		end
	}
}

	util.dumptable(ubus_objects)





conn:add( ubus_objects )
print("Objects added, starting loop")

local timer
local counter = 0
function t()
	counter = counter + 1
	local params = {
		count = counter
	}

	util.dumptable(ubus_objects)

	--conn:notify( ubus_objects.test.__ubusobj, "test.alarm", params )

	timer:set(5000)
end
timer = uloop.timer(t)
timer:set(1000)



uloop.run()