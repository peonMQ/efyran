local mq = require("mq")
local log = require("efyran/knightlinc/Write")
local commandQueue = require('commandQueue')

local function execute()
    log.Info("click yes")
    unflood_delay()
    if window_open("ConfirmationDialogBox") then
        cmd("/notify ConfirmationDialogBox Yes_Button leftmouseup")
    elseif window_open("LargeDialogWindow") then
        cmd("/notify LargeDialogWindow LDW_YesButton leftmouseup")
    end
end

-- tell all peers to click yes on dialog (rez, etc)
local function createCommand()
    if is_orchestrator() then
        cmd("/dgzexecute /yes")
    end

    commandQueue.Enqueue(function() execute() end)
end

mq.bind("/yes", createCommand)
