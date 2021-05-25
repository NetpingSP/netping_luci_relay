package.path = '../src/?.lua;../src/?/?.lua;'..package.path

local ev = require "ev"
local loop = ev.Loop.default
local websocket = require "websocket"
local util = require "luci.util"
local jsonc = require "luci.jsonc"
local uci = require "luci.model.uci".cursor()

local config = "netping_luci_relay"

local server = websocket.server.ev.listen
{
  protocols = {
    ['updating_relay_state'] = function(ws)
      local timer = ev.Timer.new(
        function()
          --[[ 
          1. Get uci changes history which were made with command "ubus call uci set ....."
          2. Remove all dublicates starting from end of list (only last - actual changes are in the list).
          3. Make JSON structure of the actual changes:
          {
            netping_luci_relay.cfg042442.state: 1,
            netping_luci_relay.cfg434875.state: 0
          }
          4.Send the stringify(JSON) to websocket.
          ]]
          local idx_uci_comm, idx_id, idx_key, idx_val = 1, 2, 3, 4
          local actual_changes = {}
          local changes = uci:changes(config)
          local i = #changes
          for i = #changes, 1, -1 do
            uci_obj = changes[i]
            if (uci_obj[idx_uci_comm] == "set") then
              local key = config .. "." .. uci_obj[idx_id] .. "." .. uci_obj[idx_key]
              local val = uci_obj[idx_val]
              if actual_changes[key] == nil then
                actual_changes[key] = val
              end
            end
          end
          local payload = jsonc.stringify(actual_changes)
          if payload ~= "{}" then
            ws:send(payload)
          else
            ws:send("No UCI changes are made. Run $ ubus call uci set '" .. '{ "config": "netping_luci_relay", "section": "@relay[1]", "values": {"state": "1"}  }\'')
          end
        end,0.4,0.4)
      timer:start(loop)
      ws:on_close(
        function()
          timer:stop(loop)
        end)
    end
    --[[
    ADD ANOTHER WEBSOCKET HERE IF NEEDED]]
  },
  port = 8082
}
print('Open web browser and refresh!')
loop:loop()

