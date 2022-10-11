local mq = require("mq")
local log = require("knightlinc/Write")

require("e4_Spells")
local follow  = require("e4_Follow")
local pet     = require("e4_Pet")
local botSettings = require("e4_BotSettings")
local groupBuffs = require("e4_GroupBuffs")
local bard = require("Class_Bard")

local timer = require("Timer")

local MIN_BUFF_DURATION = 6 * 6000 -- 6 ticks, each tick is 6s

---@class buffQueueValue
---@field public Peer string Peer name
---@field public Buff string Name of buff group
---@field public Force boolean Should we force-cast, or respect existing buff timers?

local Buffs = {
    -- my aura spell, if any
    aura = find_best_aura(),

    -- queue of incoming buff requests
    ---@type buffQueueValue[]
    queue = {},

    ---@type string my available buff groups (space separated string)
    available = "",

    -- others available buff groups (key = peer, val = space separated string)
    otherAvailable = {},

    ---@type boolean /buffon, /buffoff
    refreshBuffs = true,
}

function Buffs.Init()
    -- enqueues a buff to be cast on a peer
    -- is normally called from another peer, to request a buff
    mq.bind("/queuebuff", function(buff, peer, force)
        --print("queuebuff buff=", buff, ", peer=", peer)
        table.insert(Buffs.queue, {
            ["Peer"] = peer,
            ["Buff"] = buff,
            ["Force"] = force == "force",
        })
    end)

    bard.resumeMelody()
end

local announceBuffsTimer = timer.new_random(2 * 60) -- 2 minutes

local refreshBuffsTimer = timer.new_random(10 * 1) -- 10s

local handleBuffsTimer = timer.new_random(2 * 1) -- 2s

-- broadcasts what buff groups we can cast
function Buffs.AnnounceAvailablity()
    -- see what class group buffs I have and prepare a list of them so I can announce availability.
    local classBuffGroups = groupBuffs[class_shortname()]
    if classBuffGroups == nil then
        return
    end

    local availableBuffGroups = ""
    for groupIdx, buffGroup in pairs(classBuffGroups) do
        -- see if we have any rank of this buff
        for rowIdx, checkRow in pairs(buffGroup) do
            local spellConfig = parseSpellLine(checkRow)
            if is_spell_in_book(spellConfig.Name) then
                availableBuffGroups = availableBuffGroups .. " " .. groupIdx
                break
            end
        end
    end
    Buffs.available = trim(availableBuffGroups)
    if string.len(Buffs.available) > 0 then
        log.Info("My available buff groups: %s", Buffs.available)
        cmdf("/dgtell %s #available-buffs %s", dannet_zone_channel(), Buffs.available)
    end
end

function dannet_zone_channel()
    local name = "zone_" .. current_server() .. "_" .. zone_shortname()
    return name:lower()
end

function Buffs.Tick()
    if not is_brd() and is_casting() then
        return
    end

    if follow.spawn ~= nil or is_gm() or is_invisible() or is_hovering() or in_combat() or is_moving() or in_neutral_zone() or window_open("MerchantWnd") or window_open("GiveWnd") or window_open("BigBankWnd") or window_open("SpellBookWnd") or window_open("LootWnd") or spawn_count("pc radius 100") == 1 then
        return
    end

    if Buffs.refreshBuffs and refreshBuffsTimer:expired() then
        --log.Debug("Buff tick: refresh buffs at %s", time())
        if not Buffs.RefreshSelfBuffs() then
            if not Buffs.RefreshAura() then
                if not pet.Summon() then
                    if not pet.BuffMyPet() then
                        Buffs.RequestBuffs()
                    end
                end
            end
        end
        refreshBuffsTimer:restart()
    end

    if announceBuffsTimer:expired() then
        Buffs.AnnounceAvailablity()
        announceBuffsTimer:restart()
    end

    if is_casting() or is_hovering() or is_sitting() or is_moving() or mq.TLO.Me.SpellInCooldown() or window_open("SpellBookWnd") then
        return
    end

    --print("QUEUE LEN = ", table.getn(Buffs.queue))
    if #Buffs.queue > 0 and handleBuffsTimer:expired() then
        local req = table.remove(Buffs.queue, 1)
        if req ~= nil then
            if handleBuffRequest(req) then
                handleBuffsTimer:restart()
            end
        else
            all_tellf("ERROR queue fetch returned NIL") -- unlikely
        end
    end
end

---@param spawnID integer
function Buffs.BuffIt(spawnID)

    if Buffs.available == nil then
        log.Debug("Stopping /buffit, no group_buffs available!")
        return
    end

    if not is_peer_id(spawnID) then
        all_tellf("ERROR got a BuffIt request from unknown spawn %s", spawnID)
        return
    end

    local spawn = spawn_from_id(spawnID)
    if spawn == nil then
        all_tellf("ERROR BuffIt: spawn_from_id() failed for %s", spawnID)
        return
    end

    log.Debug("Handling /buffit request for spawn %s", spawnID)

    local spawn = spawn_from_query("id "..spawnID)
    if spawn == nil then
        all_tellf("BUFFIT FAIL, cannot find spawn ID %d in %s", spawnID, zone_shortname())
        return false
    end

    -- get the buffs for my class from spawn class default buffs.
    for idx, key in pairs(groupBuffs.Default[spawn.Class.ShortName()]) do
        local spellConfig = parseSpellLine(key)
        if spellConfig.Class == class_shortname() then
            cmdf("/queuebuff %s %s force", spellConfig.Name, spawn.Name())
        end
    end
end

function getClassBuffGroup(classShort, buffGroup)
    local buffRows = groupBuffs[classShort][buffGroup]
    if buffRows == nil then
        all_tellf("FATAL ERROR: /queuebuff did not find groupBuffs.%s entry %s", classShort, buffGroup)
        return false
    end
end

-- returns true if spell is cast
---@param req buffQueueValue
function handleBuffRequest(req)

    log.Debug("handleBuffRequest: Peer %s, buff %s, queue len %d, force = %s", req.Peer, req.Buff, #Buffs.queue, tostring(req.Force))

    local buffRows = groupBuffs[class_shortname()][req.Buff]
    if buffRows == nil then
        all_tellf("ERROR: handleBuffRequest: did not find groupBuffs.%s entry %s", class_shortname(), req.Buff)
        return false
    end

    local spawn = spawn_from_peer_name(req.Peer)
    if spawn == nil then
        -- happens when zoning
        log.Error("handleBuffRequest: Spawn not found %s", req.Peer)
        return false
    end

    target_id(spawn.ID())

    -- wait for buff populared
    delay(3000, function()
        if spawn.BuffsPopulated() then
            log.Debug("Buffs populated for %s (%s)", spawn.Name(), req.Buff)
            return true
        end
    end)
    delay(100)

    -- find the one with highest MinLevel
    local minLevel = 0
    local spellName = ""

    local level = spawn.Level()

    -- see if we have any rank of this buff
    for idx, checkRow in pairs(buffRows) do
        --print(checkRow)

        -- XXX same logic as /buffit. do refactor

        local spellConfig = parseSpellLine(checkRow)  -- XXX do not parse here, cache and reuse
        local n = tonumber(spellConfig.MinLevel)
        if n == nil then
            all_tellf("FATAL ERROR, group buff %s does not have a MinLevel setting", checkRow)
            return
        end
        -- XXX debug source of nil
        if type(n) ~= "number" then
            all_tellf("FATAL n is not a number")
        end
        if type(minLevel) ~= "number" then
            all_tellf("FATAL minLevel is not a number")
        end
        if type(level) ~= "number" then
            all_tellf("FATAL level is not a number: %s: %s", type(level), tostring(level))
        end
        if n > minLevel and level >= n then
            spellName = spellConfig.Name
            local spell = get_spell(spellName)
            if spell == nil then
                all_tellf("FATAL ERROR cant lookup %s", spellName)
                return
            end
            if is_spell_in_book(spellName) then
                spellName = spell.RankName()
                --if spell.StacksTarget() then
                    minLevel = n
                    --print("minLevel = ", n)
                --else
                    -- XXX look into: seems spell.StacksTarget() checks vs myself instead of my target... is it a mq2-lua bug ????  cant cast Symbol of Naltron from CLR with higher sytmbol on a naked WAR.
                --    cmd("/dgtell all ERROR cannot buff ", spawn.Name(), " with ", spellName, ", MinLevel ", n, " (dont stack with current buffs)")
                --end
                log.Debug("Best %s buff so far is MinLevel %d, Name %s, target L%d %s", req.Peer, spellConfig.MinLevel, spellConfig.Name, level, spawn.Name())
            end
        end
    end

    if minLevel > 0 and spellConfigAllowsCasting(spellName, spawn) then
        if not req.Force and spawn.Buff(spellName)() ~= nil and spawn.Buff(spellName).Duration() >= MIN_BUFF_DURATION then
            log.Info("handleBuffRequest: Skip \ag%s\ax %s (%s), they have buff already. %d sec", spawn.Name(), spellName, req.Buff, spawn.Buff(spellName).Duration())
            return false
        end

        -- XXX is being cast even tho target has the buff... should duck in callback
        all_tellf("Buffing \ag%s\ax with \ay%s\ax (\ay%s\ax).", spawn.Name(), spellName, req.Buff)
        castSpellRaw(spellName, spawn.ID(), "-maxtries|3")
        delay(100)
        doevents()
        delay(10000, function()
            if not is_casting() then
                return true
            end
            if not req.Force and spawn.Buff(spellName)() ~= nil and spawn.Buff(spellName).Duration() >= MIN_BUFF_DURATION then
                -- abort if they got the buff while we are casting
                -- FIXME: this often triggers when spell had completed casting
                log.Info("handleBuffRequest: My target %s has buff %s for %f sec, ducking.", mq.TLO.Target.Name(), spellName, mq.TLO.Target.Buff(spellName).Duration() / 1000)
                cmdf("/interrupt")
                return true
            end
        end)
        return true
    else
        log.Warn("\arERROR: I do not have any buffs matching %s\ax to cast on L%d %s", req.Buff, level, spawn.Name())
    end
end

-- returns true if a buff was casted
function Buffs.RefreshSelfBuffs()
    if botSettings.settings.self_buffs == nil or is_sitting() then
        return false
    end
    --log.Debug("Buffs.RefreshSelfBuffs()")
    for k, buffItem in pairs(botSettings.settings.self_buffs) do
        doevents()
        if refreshBuff(buffItem, mq.TLO.Me) then
            -- end after first successful buff
            return true
        end
    end
    return false
end

-- returns true if buff was requested
function Buffs.RequestBuffs()

    local req = botSettings.settings.request_buffs
    if req == nil then
        req = groupBuffs.Default[class_shortname()]
        if req == nil then
            -- unlikely
            all_tellf("FATAL ERROR class default buffs missing for %s", class_shortname())
            delay(20000)
            return
        end
    end

    --print("Buffs.RequestBuffs")

    local availableClasses = find_available_classes()

    for k, row in pairs(req) do
        -- "aegolism/Class|CLR/NotClass|DRU"
        local spellConfig = parseSpellLine(row)
        --log.Debug("Considering to request \ay%s\ax.", spellConfig.Name)

        local skip = false
        local classes = split_str(spellConfig.Class, ",")
        for classIdx, class in pairs(classes) do
            --log.Debug("- Class: do we have class \ax%s\ay available? %s", class, tostring(availableClasses[class] == true))
            if availableClasses[class] ~= true then
                skip = true
            end
        end

        if spellConfig.NotClass ~= nil then
            local notClasses = split_str(spellConfig.NotClass, ",")
            for classIdx, class in pairs(notClasses) do
                --log.Debug("- NotClass: do we have class \ax%s\ay available? %s", class, tostring(availableClasses[class] == true))
                if availableClasses[class] == true then
                    skip = true
                end
            end
        end

        if not skip then
            local askClass = groupBuffs.Lookup[spellConfig.Name]
            if askClass == nil then
                all_tellf("FATAL ERROR: did not find groupBuffs.Lookup entry %s", spellConfig.Name)
                return false
            end

            local buffRows = groupBuffs[askClass][spellConfig.Name]
            if buffRows == nil then
                all_tellf("FATAL ERROR: did not find groupBuffs.%s entry %s", askClass, spellConfig.Name)
                return false
            end

            -- see if we have any of this buff form on
            -- XXX assume what spell will be used and see if it will stack on me.
            local found = false
            local refresh = false
            for idx, checkRow in pairs(buffRows) do
                local o = parseSpellLine(checkRow)
                if have_buff(o.Name) then
                    local duration = mq.TLO.Me.Buff(o.Name).Duration()
                    if duration ~= nil and duration >= MIN_BUFF_DURATION then
                        --log.Debug("Will not request \ay%s\ax. I have buff \ay%s\ax for %d more ticks.", spellConfig.Name, o.Name, duration)
                        found = true
                        break
                    else
                        -- only check for free buff slots if we are not refreshing buff
                        refresh = true
                    end
                end
            end

            -- ask proper class for buff
            if not found then
                local peer = Buffs.findAvailableBuffer(spellConfig.Name)
                if peer ~= nil then
                    if not refresh and free_buff_slots() <= 0 then
                        all_tellf("\arWARN\ax: Won't ask for \ay%s\ax as I only have %d free buff slots", spellConfig.Name, free_buff_slots())
                        return true
                    else
                        log.Info("Requesting buff \ax%s\ay from \ag%s %s\ax ...", spellConfig.Name, askClass, peer)
                        cmdf("/dexecute %s /queuebuff %s %s", peer, spellConfig.Name, mq.TLO.Me.Name())
                    end
                else
                    log.Debug("No peer of required class for buff %s found nearby: %s", spellConfig.Name, askClass)
                end
            end
        else
            --log.Debug("Will not request \ay%s\ax. Required class combo is not met: \ayClass:%s, NotClass:%s\ax.", spellConfig.Name, spellConfig.Class, spellConfig.NotClass or "")
        end
    end

    return false
end

-- Find the closest buffer peer who announced they have the desired buff group available
---@return string|nil
function Buffs.findAvailableBuffer(buffGroup)
    for peer, availableGroups in pairs(Buffs.otherAvailable) do
        if availableGroups:find(buffGroup) then
            --log.Debug("peer %s, buff groups: %s", peer, buffGroups)
            return peer
        end
    end
    return nil
end

-- returns true if a buff was casted
function Buffs.RefreshAura()
    if Buffs.aura == nil or mq.TLO.Me.Aura(1)() ~= nil or is_sitting() then
        return false
    end
    castSpellRaw(Buffs.aura, nil)
    return true
end

return Buffs

