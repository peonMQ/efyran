local mq = require("mq")
local commandQueue = require('e4_commandQueue')

---@class TeleportToCommand
---@field ZoneName string

---@param command TeleportToCommand
local function execute(command)
    cast_port_to(command.ZoneName)
end

local function createCommand(name)
    name = name:lower()
    if is_orchestrator() then
        mq.cmdf("/dgzexecute /portto %s", name)
    end

    commandQueue.Enqueue(function() execute({ZoneName = name}) end)
end


mq.bind("/portto", createCommand)
