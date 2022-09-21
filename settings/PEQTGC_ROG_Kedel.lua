local settings = { }

settings.swap = {
    ["main"] = "Nightshade, Blade of Entropy|Mainhand/Aneuk Dagger of Eye Gouging|Offhand/Ruby of Determined Assault|Ranged",
    ["ranged"] = "Plaguebreeze|Ranged",
    ["noriposte"] = "Fishing Pole|Mainhand/Howling Blood-Stained Bulwark|Offhand",
}

settings.self_buffs = {
    --"Fuzzy Foothairs", -- i am Gnome

    "Veil of Intense Evolution", -- Furious Might (slot 5: 40 atk)

    "Bite of the Shissar XII/Reagent|Bite of the Shissar XII",
}

settings.combat_buffs = { -- XXX combat buffs:
    "Thief's Eyes/Kniven/MinEnd|10",        -- XXX MinEnd
}

settings.healing = {
    ["life_support"] = {
        "Nimble Discipline/HealPct|45", -- L55 Nimble Discipline (avoid most attacks, 21 min reuse)
        "Distillate of Divine Healing XI/HealPct|8",
        "Stealthy Getaway/HealPct|10", -- L70 Stealthy Getaway AA
        "Glyph of Stored Life/HealPct|5/Zone|anguish", -- Expendable AA
    }
}

settings.assist = {
    ["type"] = "Melee",
    ["ranged_distance"] = 80,
    ["engage_percent"] = 98,
    ["abilities"] = {
        "Escape/PctAggro|99", -- L59 Escape AA
        "Backstab",
        "Intimidation", -- XXX skill up
    },
    ["quickburns"] = {
        -- oow T2 bp: (increase all melee taken by 20% for 24s, 5 min reuse) Whispering Tunic of Shadows
        --"Whispering Tunic of Shadows",

        -- EPIC 2.0: Nightshade, Blade of Entropy (45% triple backstab, Deceiver's Blight Strike proc)
        "Nightshade, Blade of Entropy",

        -- timer 5:
        -- L70 Frenzied Stabbing Discipline (15 min reuse)
        "Frenzied Stabbing Discipline",

        -- timer 2:
        -- L59 Duelist Discipline (22 min reuse, 14 min reuse with epic 2.0)
        "Duelist Discipline",

        -- timer 3:
        -- L65 Twisted Chance Discipline (22 min reuse)
        "Twisted Chance Discipline",
    },
    ["longburns"] = {},
    ["fullburns"] = {},
}

settings.rogue = { -- XXX implement and rearrange settings
--[[
Auto-Hide (On/Off)=Off
Auto-Evade (On/Off)=On
Evade PctAggro=75
Sneak Attack Discipline=
PoisonPR=Bite of the Shissar XII
PoisonFR=Solusek's Burn XII
PoisonCR=E`ci's Lament XII

; timer 8 (sneak attack disc):
; L05 Elbow Strike
; L52 Thief's Vengeance
; L65 Kyv Strike
; L65 Ancient: Chaos Strike
; L69 Daggerfall
; L70 Razorarc
;Sneak Attack Discipline=Razorarc/MinEnd|50

; to skill up:
;Sneak Attack Discipline=Pick Pockets
]]--
}

return settings