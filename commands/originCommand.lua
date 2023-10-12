local mq = require("mq")
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'
local commandQueue = require('e4_CommandQueue')

local bci = broadCastInterfaceFactory()

local function execute()
    use_alt_ability("Origin")
end

local function createCommand(distance)
    if is_orchestrator() then
        bci.ExecuteZoneCommand("/origin")
    end

    commandQueue.Enqueue(function() execute() end)
end

mq.bind("/origin", createCommand)
