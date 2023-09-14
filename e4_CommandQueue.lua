local mq = require("mq")
local log = require("efyran/knightlinc/Write")

local heal    = require("efyran/e4_Heal")
local hail    = require("efyran/e4_Hail")
local buffs   = require("efyran/e4_Buffs")
local bard    = require("efyran/Class_Bard")
local follow  = require("efyran/e4_Follow")
local assist  = require("efyran/e4_Assist")
local pet     = require("efyran/e4_Pet")
local group   = require("efyran/e4_Group")

---@class CommandQueueValue
---@field public Name string Name
---@field public Arg string Argument
---@field public Arg2 string Second argument

local CommandQueue = {
    ---@type CommandQueueValue[]
    queue = {},
}

---@param name string
---@param arg? string optional argument
---@param arg2? string optional argument
function CommandQueue.Add(name, arg, arg2)
    table.insert(CommandQueue.queue, {
        Name = name,
        Arg = arg,
        Arg2 = arg2,
    })
end

-- remove by name
function CommandQueue.Remove(name)
    local idx = -1

    for k, v in pairs(CommandQueue.queue) do
        if v.Name == name then
            idx = k
        end
    end

    if idx ~= -1 then
        table.remove(CommandQueue.queue, idx)
    end
end

---@return CommandQueueValue|nil
function CommandQueue.PeekFirst()
    for k, v in ipairs(CommandQueue.queue) do
        return v
    end
    return nil
end

-- Clears the command queue
function CommandQueue.Clear()
    CommandQueue.queue = {}
end

-- Is called when peer has zoned
function CommandQueue.ZoneEvent()
    CommandQueue.Clear()
    CommandQueue.Add("zoned")
    buffs.timeZoned = os.time()
end



function CommandQueue.Process()
    --log.Debug("CommandQueue.Process()")

    local v = CommandQueue.PeekFirst()
    if v == nil then
        return
    end

    log.Info("Performing command \ay%s\ax (%s, %s)", v.Name, v.Arg, v.Arg2)

    CommandQueue.Remove(v.Name)

    if v.Name == "joingroup" then
        wait_until_not_casting()
        cmd("/squelch /target clear")
        delay(100)
        cmd("/squelch /invite")
    elseif v.Name == "joinraid" then
        wait_until_not_casting()
        cmd("/notify ConfirmationDialogBox Yes_Button leftmouseup")
        cmd("/squelch /raidaccept")
    elseif v.Name == "zoned" then
        perform_zoned_event()
    elseif v.Name == "dropinvis" then
        drop_invis()
    elseif v.Name == "playmelody" then
        bard.PlayMelody(v.Arg)
    elseif v.Name == "cure" then
        cure_player(v.Arg, v.Arg2)
    elseif v.Name == "radiantcure" then
        cast_radiant_cure()
    elseif v.Name == "buffit" then
        buffs.BuffIt(toint(v.Arg))
    elseif v.Name == "killit" then
        local filter = v.Arg2
        if filter ~= nil and not matches_filter(filter, mq.TLO.Me.Name()) then
            log.Info("Not matching filter, giving up: %s", filter)
            return
        end
        local spawn = spawn_from_id(toint(v.Arg))
        if spawn == nil or (spawn.Type() ~= "NPC" and spawn.Type() ~= "Pet") then
            return
        end
        if spawn.Distance() > 400 then
            log.Error("Wont attack, too far away %f", spawn.Distance())
            return
        end
        -- if already killing something, enqueue order
        if assist.IsAssisting() then
            if toint(v.Arg) == assist.targetID then
                return
            end

            log.Info("got told to kill but already on target, so putting order back in queue")
            -- optimization: skips filtering again
            CommandQueue.Add(v.Name, v.Arg)
            return
        end

        log.Debug("Killing %s, type %s", spawn.DisplayName(), spawn.Type())
        assist.handleAssistCall(spawn)
    elseif v.Name == "backoff" then
        local filter = v.Arg
        if filter ~= nil and not matches_filter(filter, mq.TLO.Me.Name()) then
            log.Info("BACKOFF: Not matching filter, giving up: %s", filter)
            return
        end
        assist.backoff()

    elseif v.Name == "pbaeon" then
        -- XXX impl filter
        memorizePBAESpells()
        all_tellf("PBAE ON")
        assist.PBAE = true
    elseif v.Name == "disbandall" then
        disband_all_peers()
    elseif v.Name == "usecorpsesummoner" then
        use_corpse_summoner()
    elseif v.Name == "evacuate" then
        cast_evac_spell()
    elseif v.Name == "groupheal" then
        cast_group_heal()
    elseif v.Name == "shrinkgroup" then
        shrink_group()
    elseif v.Name == "clickdoor" then
        local sender = spawn_from_peer_name(v.Arg)
        if sender == nil then
            all_tellf("NO SENDER SPAWN, IGNORING CLICK FROM %s", v.Arg)
            return
        end
        if not is_within_distance(sender, 60) then
            all_tellf("TOO FAR AWAY FROM %s (%.2f), CANT CLICK", v.Arg, sender.Distance())
            return
        end

        if v.Arg2 ~= nil and matches_filter(v.Arg2, mq.TLO.Me.Name()) then
            click_nearby_door()
        end
    elseif v.Name == "portto" then
        cast_port_to(v.Arg)
    elseif v.Name == "movetoid" then
        local filter = v.Arg2
        if filter ~= nil and not matches_filter(filter, mq.TLO.Me.Name()) then
            log.Info("movetoid: Not matching filter, giving up: %s", filter)
            return
        end
        move_to(toint(v.Arg))
    elseif v.Name == "rtz" then
        follow.RunToZone(v.Arg)
    elseif v.Name == "hailit" then
        hail.PerformHail()
    elseif v.Name == "aetl" then
        castSpellAbility(nil, "Teleport")
    elseif v.Name == "recallgroup" then
        group.RecallGroup(v.Arg, v.Arg2)
    elseif v.Name == "rezit" then
        rez_it(toint(v.Arg))
    elseif v.Name == "aerez" then
        ae_rez()
    elseif v.Name == "mgb" then
        if not have_spell(v.Arg) and not have_alt_ability(v.Arg) then
            all_tellf("FATAL: I cannot mgb this, dont have it: %s", v.Arg)
            return
        end
        cast_mgb_spell(v.Arg)
    elseif v.Name == "aecry" then
        cast_ae_cry()
    elseif v.Name == "aebloodthirst" then
        cast_ae_bloodthirst()
    elseif v.Name == "lootcorpse" then
        loot_my_corpse()
    elseif v.Name == "consentme" then
        consent_me()
    elseif v.Name == "gathercorpses" then
        gather_corpses()
    elseif v.Name == "click-yes" then

        log.Info("click yes")

        unflood_delay()
        if window_open("ConfirmationDialogBox") then
            cmd("/notify ConfirmationDialogBox ${buttonToClick}_Button leftmouseup")
        elseif window_open("LargeDialogWindow") then
            cmd("/notify LargeDialogWindow LDW_${buttonToClick}Button leftmouseup")
        end

    elseif v.Name == "finditem" then
        report_find_item(v.Arg)
    elseif v.Name == "findmissingitem" then
        report_find_missing_item(v.Arg)
    elseif v.Name == "reportclickies" then
        report_clickies()
    elseif v.Name == "wordheal" then
        cast_word_heal()
    elseif v.Name == "summonbanker" then
        local aaName = "Summon Clockwork Banker"
        if is_alt_ability_ready(aaName) then
            use_alt_ability(aaName, nil)
            return
        end

        log.Warn(aaName.." is not ready. Ready in "..mq.TLO.Me.AltAbilityTimer(aaName).TimeHMS())

        if not is_orchestrator() then
            return
        end

        ask_nearby_peer_to_activate_aa(aaName)
    elseif v.Name == "autobank" then
        autobank()
    elseif v.Name == "reportwornaugs" then
        report_worn_augs()
    elseif v.Name == "open-nearby-corpse" then
        open_nearby_corpse()
    elseif v.Name == "origin" then
        use_alt_ability("Origin")
    elseif v.Name == "use-veteran-aa" then
        use_alt_ability(v.Arg)
        delay(200)
    elseif v.Name == "dropbuff" then
        drop_buff(v.Arg)
    elseif v.Name == "mount-on" then
        mount_on()
    elseif v.Name == "burns" then
        if not in_combat() then
            log.Info("Ignoring \ay%s\ax burns request (not in combat)", v.Arg)
            return
        end
        log.Info("Enabling burns \ay%s\ax", v.Arg)
        if v.Arg == "quickburns" then
            assist.quickburns = true
        elseif v.Arg == "longburns" then
            assist.longburns = true
        elseif v.Arg == "fullburns" then
            assist.fullburns = true
        else
            log.Error("Unknown burns set '%s'", v.Arg)
        end
    elseif v.Name == "ward" then
        UseWard(v.Arg)
    elseif v.Name == "teleportbind" then
        if is_alt_ability_ready("Teleport Bind") then
            use_alt_ability("Teleport Bind")
        elseif have_alt_ability("Teleport Bind") then
            all_tellf("ERROR: Teleport Bind not ready (in %s)", mq.TLO.Me.AltAbilityTimer("Teleport Bind").TimeHMS())
        end
    elseif v.Name == "secondaryrecall" then
        if is_alt_ability_ready("Secondary Recall") then
            use_alt_ability("Secondary Recall")
        elseif have_alt_ability("Secondary Recall") then
            all_tellf("ERROR: Secondary Recall not ready (in %s)", mq.TLO.Me.AltAbilityTimer("Secondary Recall").TimeHMS())
        end
    elseif v.Name == "hastask" then
        if mq.TLO.Task(v.Arg).Index() ~= nil then
            all_tellf("Has task \ag%s\ax", v.Arg)
        else
            all_tellf("Dont have task \ar%s\ax", v.Arg)
        end
    elseif v.Name == "listtasks" then
        report_active_tasks()
    else
        all_tellf("ERROR unknown command in queue: %s", v.Name)
    end
end

-- Report all active tasks
function report_active_tasks()
    local s = ""
    for i = 1, 29 do
        if mq.TLO.Task(i).Title() ~= "" then
            s = s .. string.format("%d:%s,", i, mq.TLO.Task(i).Title())
        end
    end
    if s ~= "" then
        all_tellf("Tasks: %s", s)
    else
        all_tellf("Tasks: None")
    end
end

-- Use a ward AA (priests)
---@param kind string kind of ward ("heal", "cure")
function UseWard(kind)
    if not is_clr() and not is_dru() then
        return
    end
    if kind == "cure" then
        local aaName = "Ward of Purity" -- DoDH
        if not have_alt_ability(aaName) then
            all_tellf("I do not have AA \ar%s\ax", aaName)
            return
        end
        if is_alt_ability_ready(aaName) then
            all_tellf("Dropping %s ward '%s' ...", kind, aaName)
            use_alt_ability(aaName)
        else
            all_tellf("\ar%s ward '%s' is not ready\ax. Ready in %s", kind, aaName, mq.TLO.Me.AltAbilityTimer(aaName).TimeHMS())
        end

    elseif kind == "heal" then
        local healWards = {
            "Exquisite Benediction", -- CLR
            "Nature's Boon",         -- DRU
            "Call of the Ancients",  -- SHM
        }
        for k, aaName in pairs(healWards) do
            if have_alt_ability(aaName) then
                if is_alt_ability_ready(aaName) then
                    all_tellf("Dropping \ay%s ward\ax '%s' ...", kind, aaName)
                    use_alt_ability(aaName)
                else
                    all_tellf("\ar%s ward '%s' is not ready\ax. Ready in %s", kind, aaName, mq.TLO.Me.AltAbilityTimer(aaName).TimeHMS())
                end
                return
            end
        end
    else
        all_tellf("UseWard FATAL: unhandled kind %s", kind)
    end
end

function cast_word_heal()
    wait_until_not_casting()
    local name = ""

    -- group heals:
    -- L30 Word of Health                          (380-485 hp, cost 302 mana)
    -- L57 Word of Restoration                     (1788-1818 hp, cost 898 mana)
    -- L60 Word of Redemption                      (7500 hp, cost 1100 mana)
    -- L64 Word of Replenishment                   (2500 hp, -14 dr, -14 pr, -7 curse, cost 1100 mana)
    -- L69 Word of Vivification                    (3417-3427 hp, -21 dr, -21 pr, -14 curse, cost 1357 mana)

    -- L80 Word of Vivacity                        (4250 hp, -21 dr, -21 pr, -14 curse, cost 1540 mana)
    -- L80 Word of Vivacity Rk. II                 (4610 hp, -21 dr, -21 pr, -14 curse, cost 1610 mana)
    -- L80 Word of Vivacity Rk. III                (4851 hp, -21 dr, -21 pr, -14 curse, cost 1654 mana)
    -- L85 Word of Recovery                        (4886 hp, -21 dr, -21 pr, -14 curse, cost 1663 mana)
    -- L85 Word of Recovery Rk. II                 (5302 hp, -21 dr, -21 pr, -14 curse, cost 1738 mana)
    -- L85 Word of Recovery Rk. III                (5578 hp, -21 dr, -21 pr, -14 curse, cost 1786 mana)
    -- L90 Word of Resurgence                      (6670 hp, -27 dr, -27 pr, -18 curse, cost 1974 mana)
    -- L90 Word of Resurgence Rk. II               (7238 hp, -27 dr, -27 pr, -18 curse, cost 2063 mana)
    -- L90 Word of Resurgence Rk. III              (7614 hp, -29 dr, -29 pr, -20 curse, cost 2120 mana)
    -- L95 Word of Rehabilitation                  (9137 hp, -32 dr, -32 pr, -23 curse, cost 2253 mana)
    -- L95 Word of Rehabilitation Rk. II           (9594 hp, -32 dr, -32 pr, -23 curse, cost 2343 mana)
    -- L95 Word of Rehabilitation Rk. III         (10074 hp, -32 dr, -32 pr, -23 curse, cost 2437 mana)

    -- L100 Word of Reformation
    -- L105 Word of Greater Reformation
    -- L110 Word of Greater Restoration
    -- L115 Word of Greater Replenishment
    -- L120 Word of Greater Rejuvenation

    if is_memorized("Word of Health") then
        name = "Word of Health"
    end
    if is_memorized("Word of Restoration") then
        name = "Word of Restoration"
    end
    if is_memorized("Word of Redemption") then
        name = "Word of Redemption"
    end
    if is_memorized("Word of Replenishment") then
        name = "Word of Replenishment"
    end
    if is_memorized("Word of Vivification") then
        name = "Word of Vivification"
    end
    if is_memorized("Word of Vivacity") then
        name = "Word of Vivacity"
    end
    if is_memorized("Word of Recovery") then
        name = "Word of Recovery"
    end
    if is_memorized("Word of Resurgence") then
        name = "Word of Resurgence"
    end
    if is_memorized("Word of Rehabilitation") then
        name = "Word of Rehabilitation"
    end
    if is_memorized("Word of Reformation") then
        name = "Word of Reformation"
    end
    if is_memorized("Word of Greater Reformation") then
        name = "Word of Greater Reformation"
    end
    if is_memorized("Word of Greater Restoration") then
        name = "Word of Greater Restoration"
    end
    if is_memorized("Word of Greater Replenishment") then
        name = "Word of Greater Replenishment"
    end
    if is_memorized("Word of Greater Rejuvenation") then
        name = "Word of Greater Rejuvenation"
    end
    if name == "" then
        all_tellf("\arERROR: no word heal memorized!")
        return
    end
    castSpellAbility(nil, name)
end

-- performs various tasks when toon has finished starting up / zoning
function perform_zoned_event()
    log.Debug("I zoned into %s", zone_shortname())
    pet.ConfigureAfterZone()
    clear_ae_rezzed()
    joinCurrentHealChannel()

    if is_brd() then
        bard.resumeMelody()
    else
        memorizeListedSpells()
    end
    buffs.refreshBuffs = true
    heal.autoMed = true

    autoMapHeightFilter()
end

-- auto adjusts map height filter in some zones
function autoMapHeightFilter()

    local heights = {
        -- old
        guktop = {min = 30, max = 30},
        soltemple = {min = 10, max = 10},
        soldunga = { min = 15, max= 15},

        -- kunark?
        chardok = {min = 60, max = 60},
        sirens = {min = 50, max = 50},
        necropolis = {min = 80, max = 80},

        -- luclin
        fungusgrove = {min = 80, max = 80},     -- lucid shard camp

        -- omens
        riftseekers = {min = 120, max = 120},   -- XXX

        -- DoN
        stillmoona = {min = 50, max = 20}, -- XXX
        thundercrest = {min = 70, max = 70},
    }

    local data = heights[zone_shortname()]
    local unknown = false
    if data == nil then
        data = {min = 20, max = 20}
        unknown = true
    end

    local currentMin = mq.TLO.Window("MVW_MapToolBar/MVW_MinZEditBox").Text()
    local currentMax = mq.TLO.Window("MVW_MapToolBar/MVW_MaxZEditBox").Text()

    log.Info("autoMapHeightFilter setting min %d, max %d (was min %s, max %s)", data.min, data.max, currentMin, currentMax)

    -- NOTE: this need recent macroquest, past july 25 2023 for the SetText.
    --mq.TLO.Window("MVW_MapToolBar/MVW_MinZEditBox").SetText(string.format("%d", data.min))
    --mq.TLO.Window("MVW_MapToolBar/MVW_MinZEditBox").SetText(string.format("%d", data.min))

    -- TODO, if Height Filter button is not enabled, then enable it !
    if not unknown then
        if not mq.TLO.Window("MVW_MapToolBar/MVW_ZFilterButton").Checked() then
            log.Info("autoMapHeightFilter height filter was off, enabling now!")
            cmd("/notify MVW_MapToolBar MVW_ZFilterButton leftmouseup")
        end
    else
        if mq.TLO.Window("MVW_MapToolBar/MVW_ZFilterButton").Checked() then
            log.Info("autoMapHeightFilter height filter was on, disabling for unknown zone!")
            cmd("/notify MVW_MapToolBar MVW_ZFilterButton leftmouseup")
        end
    end

    return true
end

return CommandQueue
