local settings = { }

settings.swap = { -- XXX impl
}

settings.gems = {
    ["Multichromatic Assault"] = 1,
    ["Desolate Deeds"] = 2,
    ["Mystifying Flash"] = 3, -- mez
    ["Din of Tashan"] = 4,

    ["Shattered Consciousness"] = 6,
    ["Erradien's Animation"] = 7,
    ["Opalescent Rune"] = 8,
    ["Multichromatic Rune"] = 9,
    ["Guard of Druzzil"] = 10,
    ["Hastening of Ellowind"] = 11,
    ["Voice of Cognizance"] = 12,
}

settings.mount = "Glowing Black Drum"

settings.self_buffs = {

    -- slot 9: 350 mana, slot 15: 350 hp
    "Familiar of the Emerald Jungle",

    -- self rune, slot 3:
    -- L66 Ethereal Rune (absorb 1950 dmg)
    -- L6x Eldritch Rune AA
    -- L71 Draconic Rune Rk. II (absorb 3019 dmg)
    -- L76 Opalescent Rune Rk. II (absorb 7751 dmg)
    "Eldritch Rune/CheckFor|Opalescent Rune",
    "Opalescent Rune/CheckFor|Eldritch Rune/MinMana|50",

    -- self rune, slot 1:
    -- L75 Polychromatic Rune (absorb 2610 dmg, proc ae stun on fade)
    -- L80 Multichromatic Rune (absorb 6861 dmg, proc ae stun on fade)
    "Multichromatic Rune/MinMana|60",

    -- targeted rune, slot 2:
    -- L74 Brimstone Body, Rk. II (absorb 690 dmg)

    "Voice of Cognizance/MinMana|30",

    "Guard of Druzzil/MinMana|80",
}

settings.combat_buffs = { -- XXX impl
--[[
; L63 Night's Dark Terror (scarecrow, Lifetap Strike proc, 45 atk, 120 dex) - DOES not stack with Avatar
; L70 Mana Flare (timer 7, trigger Mana Flare Strike, dmg 700)
Combat Buff=Mana Flare/Arctander
Combat Buff=Mana Flare/Blastar
Combat Buff=Mana Flare/Brann
Combat Buff=Mana Flare/Fandinu
Combat Buff=Mana Flare/Redito
Combat Buff=Mana Flare/Myggan
]]--
}

settings.healing = {
    ["life_support"] = {
        "Self Stasis/HealPct|55",

        -- L70 Color Shock AA
        -- "Color Shock/HealPct|50",  -- XXX get the AA

        -- L65 Doppelganger AA
        --"Doppelganger/HealPct|30", -- XXX get the AA

        "Distillate of Divine Healing XIII/HealPct|12",

        -- L6x Mind Over Matter AA Rank 1 (id:5906 - slot1: mana shield absorb damage up to 50%, 10 hits)
        -- L68 Mind Over Matter AA Rank 2 (id:5907 - slot1: mana shield absorb damage up to 50%, 20 hits)
        -- L69 Mind Over Matter AA Rank 3 (id:xxx , 30 hits)
        -- Rank 4 - 40 hits
        -- Rank 5 - 50 hits
        -- Rank 6 - 60 hits
        --"Mind Over Matter/HealPct|30",       -- XXX get the AA
    }
}

settings.pet = {
    --["auto"] = false,

    ["heals"] = {},
    ["buffs"] = {
        "Hastening of Ellowind/MinMana|50",
    },
}

settings.assist = {
    ["nukes"] = { -- XXX implement
        -- lower aggro:
        -- L61 Boggle (decrease hate by 500)
        --"Boggle/PctAggro|99/Gem|2", -- XXX PctAggro

        -- chromatic nukes:
        -- L69 Colored Chaos (CHROMATIC, 1600 hp, cost 425 mana)

        ["main"] = {
            -- magic nukes:
            -- L07 Chaotic Feedback (28-32 hp, 1s stun, 16 mana)
            -- L16 Sanity Warp (81-87 hp, 1s stun, 38 mana)
            -- L21 Chaos Flux (152-175 hp, 1s stun, 67 mana)
            -- L32 Anarchy (264-275 hp, 1s stun, 99 mana)
            -- L43 Discordant Mind (387 hp, 1s stun, 126 mana)
            -- L54 Dementia (571 hp, 1s stun, 169 mana)
            -- L58 Dementing Visions (836 hp, 239 mana)
            -- L64 Insanity (1100 hp, cost 300 mana)
            -- L65 Madness of Ikkibi (1210 hp, cost 330 mana)
            -- L65 Ancient: Chaos Madness (1320 hp, cost 360 mana)
            -- L68 Psychosis (1513 hp, cost 375 mana)
            -- L70 Ancient: Neurosis (1634 hp, cost 398 mana)
            -- L73 Polychromatic Assault (1892 hp, chromatic resist, cost 445 mana)
            -- L78 Multichromatic Assault (2459 hp, chromatic resist, cost 537 mana)
            "Multichromatic Assault/NoAggro/MinMana|30",
        },
    },

    ["debuffs"] = { -- XXX impl
        -- slow:
        -- L09 Languid Pace (17-30% slow, 2.7 min, 50 mana)
        -- L23 Tepid Deeds (31-50% slow, 2.7 min, 100 mana)
        -- L41 Shiftless Deeds (46-65% slow, 2.7 min, 200 mana)
        -- L57 Forlorn Deeds (67-70% slow, 2.9 min, 225 mana)
        -- L65 Dreary Deeds (MAGIC: 70% slow, resist adj -10, 1.5 min, cost 270 mana)
        -- L69 Desolate Deeds (MAGIC: 70% slow, resist adj -30, 1.5 min, cost 300 mana)
        "Desolate Deeds/MaxTries|2",
    },

    ["debuffs_on_command"] = { -- XXX impl
        -- disempower:
        -- L04 Enfeeblement (-18-20 str, -3 ac, cost 20 mana)
        -- L16 Disempower (-9-12 sta, -13-15 str, -6-9 ac)
        -- L25 Listless Power (-22-35 agi, -22-35 str, -10-18 ac, cost 90 mana)
        -- L40 Incapacitate (-45-55 agi, -45-55 str, -21-24 ac, cost 150 mana)
        -- L53 Cripple (-58-105 dex, -68-115 agi, -68-115 str, -30-45 ac, cost 225 mana)
        -- L66 Synapsis Spasm (-100 dex, -100 agi, -100 str, -39 ac, cost 225 mana)
        -- L71 Fractured Consciousness (-106 dex, -106 agi, -106 str, -40 ac, -1% dual wield, cost 225 mana)
        -- L76 Shattered Consciousness (-132 dex, -132 agi, -132 str, -50 ac, -5% dual wield, cost 225 mana)
        "Shattered Consciousness/MaxTries|2/Gem|2",

        -- tash:
        -- L57 Tashanian (-37-43 mr, cost 40 mana)
        -- L61 Howl of Tashan (-48-50 mr, cost 40 mana)
        -- L72 Echo of Tashan Rk. II (-62-63 mr, increase incoming damage by 1%, cost 40 mana)
        -- L77 Din of Tashan Rk. II (-67-68 mr, increase incoming damage by 1%, cost 40 mana)
        "Din of Tashan/MaxTries|2",
    },

    ["quickburns"] = {-- XXX implememt !!!
        -- oow T1 bp: 30 sec, -1% spell resist rate, 5 min reuse. Charmweaver's Robe (Bedazzling Eyes)
        -- oow T2 bp: 42 sec, -1% spell resist rate, 5 min reuse. Mindreaver's Vest of Coercion (Bedazzling Aura)
        --"Mindreaver's Vest of Coercion",
    },

    ["pbae"] = { -- XXX impl
        -- ae stun:
        -- L03 Color Flux (4s stun/L55?, aerange 20, recast 12s)
        -- L20 Color Shift (6s stun/L55?, aerange 25, recast 12s)
        -- L43 Color Skew (8s stun/L55?, aerange 30, recast 12s)
        -- L52 Color Slant (8s stun/L55?, -100 mana, aerange 35, recast 12s)
        -- L63 Color Cloud (timer 3, 8s stun/L65, aerange 30, recast 12s)   XXX best for pop stuns then!?               XXX get spell
        -- L69 Color Snap (timer 3, 6s stun/L70, aerange 30, recast 12s)                                                XXX get spell
        -- L74 Color Collapse (timer 3, 6s stun/L78, aerange 30, recast 12s)
        -- L79 Color Cataclycsm (timer 3, 6s stun/L83, aerange 30, recast 12s)

        -- Stun/L65
        --"Color Cloud/Gem|2/MinMana|5",

        -- Stun/L70
        --"Color Snap/Gem|1/MinMana|5",
    },
}

settings.enchanter = { -- XXX impl / rearrange settings
    ["gather_mana_pct"] = 30, -- XXX impl. was GatherMana Pct in e3
    ["auto_mez"] = false, -- XXX impl + impl toggle /mezon, /mezoff

    -- XXX impl: will allow enc to chain rune tanks during fight etc (when /buffoff)
    --[[
    RuneTarget=
    RuneSpell=
    AutoRune (On/Off)=Off
    ]]--

    ["mez"] = { -- XXX impl, use if auto_mez is true
        -- ae mez:
        -- L16 Mesmerization (0.4 min/L55, cost 70 mana)
        -- L52 Fascination (36 sec/L55, cost 200 mana)
        -- L62 Word of Morell (0.3 min/L65, aerange 30, cost 300 mana)
        -- L65 Bliss of the Nihil (0.6 min/L68, aerange 25, cost 850 mana)

        -- Hammer of Delusions (tacvi class click with Euphoria)
        "Hammer of Delusions/MaxLevel|73", -- XXX impl MaxLevel filter

        -- ae mez:
        -- L16 Mesmerization (0.4 min/L55, 41% memblur, 30 aerange)
        -- L52 Fascination (0.6 min/L55, resist adj -10, 41% memblur, 35 aerange)
        -- L65 Bliss of the Nihil (0.6 min/L68, 25 aerange, 6 sec recast)
        -- L69 Wake of Felicity (0.9 min/L70, 25 aerange, 6 sec recast)
        "Wake of Felicity/MaxLevel|70/MinMobs|6", -- XXX impl MinMobs filter. will only cast if at least 5 mobs in "unsafe radius"

        -- single mez:
        -- L02 Mesmerize         (0.4 min/L55, 41% memblur, 20 mana)
        -- L13 Enthrall          (0.8 min/L55, 41% memblur, 50 mana)
        -- L30 Entrance          (1.2 min/L55, 45% memblur, 85 mana)
        -- L47 Dazzle            (1.6 min/L55, 41% memblur, 125 mana)
        -- L54 Glamour of Kintaz (0.9 min/L57, resist adj -10, 70% memblur, 125 mana)
        -- L59 Rapture           (0.7 min/L61, resist adj -1000, 80% memblur, 250 mana)
        -- L61 Apathy            (0.9 min/L62, reisst adj -10, 70% memblur, 225 mana)
        -- L63 Sleep             (0.9 min/L65, resist adj -10, 75% memblur, 275 mana)
        -- L64 Bliss             (0.9 min/L68, resist adj -10, 80% memblur, 300 mana)
        -- L67 Felicity          (0.9 min/L70, resist adj -10, 70% memblur, 340 mana)
        -- L69 Euphoria          (0.9 min/L73, resist adj -10, 70% memblur, 375 mana)
        "Euphoria/MinMana|10/MaxLevel|73",

        -- L68 Stasis   I AA (1.0 min/L73, resist adj -1000, 80% memblur, 36 min reuse)
        -- L69 Stasis  II AA (2.0 min/L73, resist adj -1000, 80% memblur, 36 min reuse)
        -- L70 Stasis III AA (3.0 min/L73, resist adj -1000, 80% memblur, 36 min reuse)
        "Stasis/MaxLevel|73",
    },

    ["charm"] = { -- XXX impl
        -- unresistable charms:
        -- L48 Ordinance (-1000 magic, charm/L52, 0.8 min, 5m recast)
        -- L60 Dictate (-1000 magic, charm/L58, 0.8 min, 5m recast)
        -- L70 Ancient: Voice of Muram (-1000 magic, charm/L70, 0.8 min, 5m recast)
        --- Edict of Command Rank 1 AA (id:8196, magic -1000, charm/70, 2 min set duration)
        --- Edict of Command Rank 2 AA (id:8197, magic -1000, charm/70, 4 min set duration)
        --- Edict of Command Rank 3 AA (id:8198, magic -1000, charm/70, 6 min set duration)
        "Edict of Command/MaxLevel|70",

        -- charms:
        -- L11 Charm (magic, charm/L25, 20.5 min)
        -- L23 Beguile (magic, charm/L37, 20.5 min)
        -- L37 Cajoling Whispers (magic, charm/L46, 20.5 min)
        -- L46 Allure (magic, charm/L51, 20.5 min)
        -- L53 Boltran's Agacerie (-10 magic, charm/L53, 7.5 min)
        -- L62 Beckon (magic, charm/L57, 7.5 min)
        -- L64 Command of Druzzil (magic, charm/L64, 7.5 min). 5s cast time, 1.5s recast
        -- L68 Compel (magic, charm/L67, 7.5 min). 5s cast time, 1.5s recast
        -- L70 True Name (magic, charm/L69, 7.5 min). 5s cast time, 1.5s recast
        -- L70 Ancient: Voice of Muram (magic -1000, charm/70, 0.8 min set duration). 5s cast time, 5 min recast
        "Ancient: Voice of Muram/MaxLevel|70",
        --"True Name/MaxLevel|69",
    },
}

return settings
