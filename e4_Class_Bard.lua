local defaultMelody = "general"

local Bard = { currentMelody = "" }

function Bard.DoEvents()
    -- print('Bard.DoEvents')
    if Bard.currentMelody == "" then
        Bard.ScribeSongSet(defaultMelody)
    end
end

-- memorize and twist given songset
function Bard.ScribeSongSet(name)

    if botSettings.settings.songs == nil then
        mq.cmd.dgtell("ERROR no bard songs declared")
        mq.cmd.beep(1)
        mq.delay(50000)
        return
    end

    local songSet = botSettings.settings.songs[name]
    if songSet == nil then
        mq.cmd.dgtell("ERROR no such song set", name)
        mq.cmd.beep(1)
        return
    end
    -- tprint(songSet)
    
    print("Scribing bard song set ", name)

    local songGems = ""
    for v, songRow in pairs(songSet) do
        -- War March of Muram/Gem|4
        for songName, gemNumber in string.gmatch(songRow, "([A-Za-z' ]+)/Gem|(%d+)") do
            print("k:",songName, ", v:", gemNumber)

            if mq.TLO.Me.Book(songName)() == nil then
                mq.cmd.dgtell("ERROR don't know bard song", songName)
                mq.cmd.beep(1)
                return
            end

            -- make sure that song is scribed, else scribe it
            if mq.TLO.Me.Gem(gemNumber).Name() ~= songName then
                mq.cmd.twist("off")
                print("SCRIBE SONG IN GEM ", gemNumber, ": want:", songName, ", have:", mq.TLO.Me.Gem(gemNumber).Name())
                mq.cmd.memorize('"'..songName..'"', gemNumber)
                mq.delay(3000)  -- XXX 3s
            end

            songGems = songGems .. gemNumber .. " "
         end
    end

    mq.cmd.twist(songGems)
    Bard.currentMelody = name
end

mq.bind("/playmelody", function(name, called)
    if not called then
        --mq.cmd.dgzexecute("/playmelody", name, true) -- everyone in current zone
        mq.cmd.dgexecute("brd", "/playmelody", name, true) -- all bards
    end

    if mq.TLO.Me.Class.ShortName() == "BRD" then
        Bard.ScribeSongSet(name)
    end
end)

return Bard
