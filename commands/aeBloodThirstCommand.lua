local commandQueue = require("CommandQueue")

local function execute()
    cast_ae_bloodthirst()
end

-- MGB BER Bloodthirst
local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

bind("/aebloodthirst", createCommand)
