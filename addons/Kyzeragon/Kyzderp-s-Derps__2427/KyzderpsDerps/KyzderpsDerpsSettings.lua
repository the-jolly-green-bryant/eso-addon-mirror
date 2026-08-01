-----------------------------------------------------------
-- Kyzderp's Derps
-- @author Kyzeragon
-----------------------------------------------------------
local KD = KyzderpsDerps

-- Return a new array of just NPC names, to be used in dropdown
local function getNpcNames()
    local newArray = {}

    if not KyzderpsDerps.savedValues.customTargetFrame.npcCustom then return newArray end

    for name, _ in pairs(KyzderpsDerps.savedValues.customTargetFrame.npcCustom) do
        table.insert(newArray, name)
    end

    return newArray
end

-- Return a new array of just player names, to be used in dropdown
local function getPlayerNames()
    local newArray = {}

    if not KyzderpsDerps.savedValues.customTargetFrame.playerCustom then return newArray end

    for name, _ in pairs(KyzderpsDerps.savedValues.customTargetFrame.playerCustom) do
        table.insert(newArray, name)
    end

    return newArray
end

local MUNDUS_BUFFS = {
    [13940] = "The Warrior",
    [13943] = "The Mage",
    [13974] = "The Serpent",
    [13975] = "The Thief",
    [13976] = "The Lady",
    [13977] = "The Steed",
    [13978] = "The Lord",
    [13979] = "The Apprentice",
    [13980] = "The Ritual",
    [13981] = "The Lover",
    [13982] = "The Atronach",
    [13984] = "The Shadow",
    [13985] = "The Tower",
}

local mundusPveIds, invertedPveIds, mundusPvpIds, invertedPvpIds
local selectedPveAllowed, selectedPveAvailable, selectedPvpAllowed, selectedPvpAvailable
local function RefreshMundusList()
    mundusPveIds = {}
    invertedPveIds = {}
    mundusPvpIds = {}
    invertedPvpIds = {}
    for id, _ in pairs(MUNDUS_BUFFS) do
        if (KyzderpsDerps.savedOptions.antispud.mundus.pve[id]) then
            table.insert(mundusPveIds, id)
        else
            table.insert(invertedPveIds, id)
        end

        if (KyzderpsDerps.savedOptions.antispud.mundus.pvp[id]) then
            table.insert(mundusPvpIds, id)
        else
            table.insert(invertedPvpIds, id)
        end
    end
end

local function GetMundusNames(origList)
    local names = {}
    for _, id in ipairs(origList) do
        table.insert(names, MUNDUS_BUFFS[id])
    end
    return names
end

local function CreateBTGSettings()
    local controls = {
            {
                type = "description",
                title = "Buff The Group Integration",
                text = "The following settings enable or disable Buff The Group addon's frames based on your equipped sets and skills. If turned OFF, the frame for that buff will not be changed, so it retains your own settings. \"Anti-Spud > Check equipped items\" above must be enabled for this to work.",
                width = "full",
            },
            {
                type = "checkbox",
                name = "Auto toggle Powerful Assault",
                tooltip = "Enable or disable Powerful Assault frame if you are wearing Powerful Assault",
                default = false,
                getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.pa end,
                setFunc = function(value)
                    KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.pa = value
                end,
                width = "full",
                disabled = function()
                    return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                end,
            },
            {
                type = "checkbox",
                name = "Auto toggle Major Slayer",
                tooltip = "Enable or disable Major Slayer frame if you are wearing Roaring Opportunist, Master Architect, or War Machine",
                default = false,
                getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorSlayer end,
                setFunc = function(value)
                    KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorSlayer = value
                end,
                width = "full",
                disabled = function()
                    return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                end,
            },
            {
                type = "checkbox",
                name = "Auto toggle Major Courage",
                tooltip = "Enable or disable Major Courage frame if you are wearing Olorime or Spell Power Cure",
                default = false,
                getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorCourage end,
                setFunc = function(value)
                    KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorCourage = value
                end,
                width = "full",
                disabled = function()
                    return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                end,
            },
            {
                type = "checkbox",
                name = "Auto toggle Minor Berserk",
                tooltip = "Enable or disable Minor Berserk frame if you have slotted Combat Prayer",
                default = false,
                getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.minorBerserk end,
                setFunc = function(value)
                    KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.minorBerserk = value
                end,
                width = "full",
                disabled = function()
                    return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                end,
            },
            {
                type = "checkbox",
                name = "Auto toggle Major Resolve",
                tooltip = "Enable or disable Major Resolve frame if you have slotted Expansive Frost Cloak",
                default = false,
                getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorResolve end,
                setFunc = function(value)
                    KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorResolve = value
                end,
                width = "full",
                disabled = function()
                    return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                end,
            },
            {
                type = "checkbox",
                name = "Auto toggle Empower",
                tooltip = "Enable or disable Empower frame if you have slotted Empowering Grasp or are wearing Galenwe",
                default = false,
                getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.empower end,
                setFunc = function(value)
                    KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.empower = value
                end,
                width = "full",
                disabled = function()
                    return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                end,
            },
            {
                type = "checkbox",
                name = "Auto toggle Pillager's Profit",
                tooltip = "Enable or disable Pillager's Profit cooldown frame if you are wearing the set",
                default = false,
                getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.pp end,
                setFunc = function(value)
                    KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.pp = value
                end,
                width = "full",
                disabled = function()
                    return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                end,
            },
        }

    if (btg and btgData and btgData.buffs[19] == zo_strformat(SI_ABILITY_NAME, GetAbilityName(163401))) then
        table.insert(controls, {
                type = "checkbox",
                name = "Auto toggle Aura of Pride",
                tooltip = "Enable or disable Aura of Pride frame if you are wearing Spaulder of Ruin",
                default = false,
                getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.spaulder end,
                setFunc = function(value)
                    KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.spaulder = value
                end,
                width = "full",
                disabled = function()
                    return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                end,
            })
    end

    return controls
end

---------------------------------------------------------------------
-- Misc settings
---------------------------------------------------------------------
local collectibleIds = {
    479, -- Witchmother's Whistle
    1167, -- The Pie of Misrule
    1168, -- Breda's Bottomless Mead Mug
    9012, -- Jubilee Cake 2021
    10287, -- Jubilee Cake 2022
    11089, -- Jubilee Cake 2023
    12422, -- Jubilee Cake 2024
    13520, -- Jubliee Cake 2025
    14325, -- Jubilee Cake 2026
    0, -- None
}
local collectibleNames = {
    GetCollectibleName(479), -- Witchmother's Whistle
    GetCollectibleName(1167), -- The Pie of Misrule
    GetCollectibleName(1168), -- Breda's Bottomless Mead Mug
    GetCollectibleName(9012), -- Jubilee Cake 2021
    GetCollectibleName(10287), -- Jubilee Cake 2022
    GetCollectibleName(11089), -- Jubilee Cake 2023
    GetCollectibleName(12422), -- Jubilee Cake 2023
    GetCollectibleName(13520), -- Jubliee Cake 2025
    GetCollectibleName(14325), -- Jubilee Cake 2026
    "- None -", -- None
}

local function CreateMiscSettings()
    local controls = {
        {
            type = "dropdown",
            name = "Use collectible on login",
            tooltip = "Specify a collectible to use when you first load into a character",
            choices = collectibleNames,
            choicesValues = collectibleIds,
            getFunc = function() return KyzderpsDerps.savedOptions.misc.loginCollectible end,
            setFunc = function(id)
                    KyzderpsDerps:dbg("selected " .. tostring(id))
                    KyzderpsDerps.savedOptions.misc.loginCollectible = id
                end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Block \"Item not ready yet\"",
            tooltip = "Prevent the \"Item not ready yet\" text from showing up in alerts",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.misc.blockItemNotReady end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.misc.blockItemNotReady = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Block \"Kill Enemies in the Night Market\"",
            tooltip = "Prevent the \"Kill Enemies in the Night Market\" text from showing up in center-screen announcements",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.misc.suppressKillEnemiesNM end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.misc.suppressKillEnemiesNM = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "In-combat reticle",
            tooltip = "Turn the reticle red while you are in combat",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.misc.combatReticle end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.misc.combatReticle = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Automatic repair kit",
            tooltip = "Automatically use a repair kit to repair gear that drops to 1% durability",
            default = true,
            getFunc = function() return KyzderpsDerps.savedOptions.misc.repair end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.misc.repair = value
                KyzderpsDerps.AutoRepair.Initialize()
            end,
            width = "full",
        },
    }

    table.insert(controls, KyzderpsDerps.Loot.GetSettings())
    table.insert(controls, KyzderpsDerps.GroupLoot.GetSettings())
    table.insert(controls, KyzderpsDerps.Tribute.GetSettings())
    local scoreFormatSettings = KyzderpsDerps.ScoreFormat.GetSettings()
    for _, setting in ipairs(scoreFormatSettings) do
        table.insert(controls, setting)
    end
    table.insert(controls, KyzderpsDerps.Tomes.GetSettings())
    table.insert(controls, {
        type = "description",
        title = nil,
        text = "The |c99FF99/wayshrine|r command can be used to quickly port to a wayshrine. It will search your group, friends, and guilds for a player in the desired zone below. If none are found in that zone, it will attempt to port you to any overland zone or, failing that, outside of an owned home that's close to a wayshrine.",
        width = "full",
    })
    table.insert(controls, {
        type = "description",
        title = nil,
        text = function()
            local zoneId = KyzderpsDerps.savedOptions.misc.wayshrineZoneId
            if (not zoneId) then
                return zo_strformat("|cFF0000<<1>>|r is not a valid zone ID!", WINDOW_MANAGER:GetControlByName("KyzderpsDerps#WayshrineEditBox").editbox:GetText())
            end
            return zo_strformat("|c99FF99/wayshrine|r will try to port you to |c99FF99<<1>> (zone ID <<2>>)|r before overland zones.",
                GetZoneNameById(zoneId), zoneId)
        end,
        width = "full",
    })
    table.insert(controls, {
        type = "editbox",
        name = "/wayshrine zone ID",
        width = "full",
        default = "849",
        tooltip = "The zone ID that you want |c99FF99/wayshrine|r to prioritize porting you to. Examples:\n849 - Vvardenfell\n1011 - Summerset\n1443 - West Weald",
        getFunc = function() return tostring(KyzderpsDerps.savedOptions.misc.wayshrineZoneId) end,
        setFunc = function(id)
            KyzderpsDerps.savedOptions.misc.wayshrineZoneId = tonumber(id)
        end,
        isMultiline = false,
        isExtraWide = false,
        reference = "KyzderpsDerps#WayshrineEditBox"
    })
    table.insert(controls, {
        type = "description",
        title = nil,
        text = "Similarly, |c99FF99/ktp|r allows you to port to a player or zone, with fallbacks. For example, |c99FF99/ktp reap|r will try to port you to a player who is in Reaper's March, and |c99FF99/ktp kyzer|r will try to port to a group member, friend, or guild member with a name containing |c99FF99kyzer|r.",
        width = "full",
    })
    table.insert(controls, {
        type = "checkbox",
        name = "Auto-select zone at wayshrine if fallback",
        tooltip = "If you try to use |c99FF99/wayshrine|r or |c99FF99/ktp|r to port to a specific zone, but no one could be found in the zone so it ported you to a fallback instead, automatically select the originally intended zone on the map when you interact with a wayshrine. For example, if I |c99FF99/ktp reap|r because I wanted to go to Reaper's March, but the fallback ported me to someone in Solstice instead, then, when I interact with the wayshrine, the map will automatically change to Reaper's March so I can select a wayshrine from there",
        default = false,
        getFunc = function() return KyzderpsDerps.savedOptions.misc.openMapForFallback end,
        setFunc = function(value)
            KyzderpsDerps.savedOptions.misc.openMapForFallback = value
        end,
        width = "full",
    })
    return controls
end

function KyzderpsDerps:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    -- Register the Options panel with LAM
    local panelData =
    {
        type = "panel",
        name = "Kyzderp's Derps",
        author = "Kyzeragon",
        version = KyzderpsDerps.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local spudStateChoices, spudStateValues = KD.AntiSpud.BuildSettings()

    -- Set the actual panel data
    local optionsData = {
        {
            type = "header",
            name = "General Settings",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug",
            tooltip = "Show lots of spam",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.general.debug end,
            setFunc = function(value) KyzderpsDerps.savedOptions.general.debug = value end,
            width = "full",
        },
        {
            type = "submenu",
            name = "Custom Target Name",
            controls = {
                {
                    type = "checkbox",
                    name = "Show Frame",
                    tooltip = "Show frame to allow moving or editing settings",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.move end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.customTargetFrame.move = value
                        CustomTargetCustomName:SetHidden(not value)
                        if (value) then
                            CustomTargetCustomNameLabel:SetText("Sample Name")
                        end
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Text Size",
                    min = 12,
                    max = 72,
                    step = 2,
                    default = 48,
                    width = "full",
                    getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.size end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.customTargetFrame.size = value
                        CustomTargetCustomNameLabel:SetFont("$(BOLD_FONT)|"..value.."|soft-shadow-thick")
                    end,
                },
-------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = "NPC Target",
                    controls = {
                        {
                            type = "checkbox",
                            name = "Show NPC Names",
                            tooltip = "Display large target name for NPCs",
                            default = true,
                            getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.npc.enable end,
                            setFunc = function(value) KyzderpsDerps.savedOptions.customTargetFrame.npc.enable = value end,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Show Only Filter",
                            tooltip = "Display names for NPCs only if they are in the custom filter",
                            default = false,
                            getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.npc.useFilter end,
                            setFunc = function(value) KyzderpsDerps.savedOptions.customTargetFrame.npc.useFilter = value end,
                            width = "full",
                            disabled = function() return not KyzderpsDerps.savedOptions.customTargetFrame.npc.enable end,
                        },
                        {
                            type = "header",
                            name = "Custom Filter",
                            width = "half",
                        },
                        {
                            type = "editbox",
                            name = "Add an NPC",
                            width = "full",
                            tooltip = "Enter the full NPC name exactly as it appears, case sensitive!",
                            getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterBox").editbox:GetText() end,
                            setFunc = function(name)
                                if (name == "") then return end

                                -- Clear the textbox
                                WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterBox").editbox:SetText("")

                                -- Add it to the dropdown
                                local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList")
                                local newEntry = {
                                    customName = name,
                                    color = {1, 1, 1},
                                }
                                KyzderpsDerps.savedValues.customTargetFrame.npcCustom[name] = newEntry
                                namesDropdown:UpdateChoices(getNpcNames())
                                namesDropdown.dropdown:SetSelectedItem(name)
                            end,
                            isMultiline = false,
                            isExtraWide = false,
                            reference = "KyzderpsDerps#NpcFilterBox",
                        },
                        {
                            type = "button",
                            name = "Most Recent Target",
                            tooltip = "Uses the most recently *displayed* NPC name",
                            width = "full",
                            func = function()
                                local editbox = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterBox").editbox
                                editbox:SetText(KyzderpsDerps.recentNpc)
                                editbox:TakeFocus()
                            end
                        },
                        {
                            type = "dropdown",
                            name = "Select NPC",
                            width = "full",
                            tooltip = "Choose an NPC",
                            choices = getNpcNames(),
                            getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem() end,
                            setFunc = function(name) end,
                            reference = "KyzderpsDerps#NpcFilterList",
                        },
                        {
                            type = "editbox",
                            name = "Custom Name",
                            width = "full",
                            tooltip = "Enter what you want the name to show up as",
                            getFunc = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                local selected = KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName]
                                if (selected) then return selected.customName end
                                return ""
                            end,
                            setFunc = function(name)
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName].customName = name
                            end,
                            isMultiline = false,
                            isExtraWide = false,
                            reference = "KyzderpsDerps#NpcCustomBox",
                            disabled = function()
                                local selected = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                return selected == ""
                            end
                        },
                        {
                            type = "colorpicker",
                            name = "Custom Color",
                            getFunc = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()

                                local selected = KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName]
                                if (selected) then return unpack(selected.color) end
                                return unpack({1, 1, 1})
                            end,
                            setFunc = function(r, g, b)
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName].color = {r, g, b}
                            end,
                            disabled = function()
                                local selected = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                return selected == ""
                            end
                        },
                        {
                            type = "button",
                            name = "Remove",
                            width = "full",
                            func = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName] = nil
                                local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList")
                                namesDropdown:UpdateChoices(getNpcNames())
                            end
                        },
                    },
                },
-------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = "Player Target",
                    controls = {
                        {
                            type = "checkbox",
                            name = "Show Player Names",
                            tooltip = "Display large target name for players",
                            default = true,
                            getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.player.enable end,
                            setFunc = function(value) KyzderpsDerps.savedOptions.customTargetFrame.player.enable = value end,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Show Only Filter",
                            tooltip = "Show player name only if they are in the custom filter",
                            default = false,
                            getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.player.useFilter end,
                            setFunc = function(value) KyzderpsDerps.savedOptions.customTargetFrame.player.useFilter = value end,
                            width = "full",
                            disabled = function() return not KyzderpsDerps.savedOptions.customTargetFrame.player.enable end,
                        },
                        {
                            type = "header",
                            name = "Custom Filter",
                            width = "half",
                        },
                        {
                            type = "editbox",
                            name = "Add a Player",
                            width = "full",
                            tooltip = "Enter the full player name exactly as it appears, including the @. Case sensitive!",
                            getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterBox").editbox:GetText() end,
                            setFunc = function(name)
                                if (name == "") then return end

                                -- Clear the textbox
                                WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterBox").editbox:SetText("")

                                -- Add it to the dropdown
                                local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList")
                                local newEntry = {
                                    customName = name,
                                    color = {1, 1, 1},
                                }
                                KyzderpsDerps.savedValues.customTargetFrame.playerCustom[name] = newEntry
                                namesDropdown:UpdateChoices(getPlayerNames())
                                namesDropdown.dropdown:SetSelectedItem(name)
                            end,
                            isMultiline = false,
                            isExtraWide = false,
                            reference = "KyzderpsDerps#PlayerFilterBox",
                        },
                        {
                            type = "button",
                            name = "Most Recent Target",
                            tooltip = "Uses the most recently *displayed* player name",
                            width = "full",
                            func = function()
                                local editbox = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterBox").editbox
                                editbox:SetText(KyzderpsDerps.recentPlayer)
                                editbox:TakeFocus()
                            end
                        },
                        {
                            type = "dropdown",
                            name = "Select Player",
                            width = "full",
                            tooltip = "Choose a player",
                            choices = getPlayerNames(),
                            getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem() end,
                            setFunc = function(name) end,
                            reference = "KyzderpsDerps#PlayerFilterList",
                        },
                        {
                            type = "editbox",
                            name = "Custom Name",
                            width = "full",
                            tooltip = "Enter what you want the name to show up as",
                            getFunc = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                local selected = KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName]
                                if (selected) then return selected.customName end
                                return ""
                            end,
                            setFunc = function(name)
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName].customName = name
                            end,
                            isMultiline = false,
                            isExtraWide = false,
                            reference = "KyzderpsDerps#PlayerCustomBox",
                            disabled = function()
                                local selected = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                return selected == ""
                            end
                        },
                        {
                            type = "colorpicker",
                            name = "Custom Color",
                            getFunc = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()

                                local selected = KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName]
                                if (selected) then return unpack(selected.color) end
                                return unpack({1, 1, 1})
                            end,
                            setFunc = function(r, g, b)
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName].color = {r, g, b}
                            end,
                            disabled = function()
                                local selected = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                return selected == ""
                            end
                        },
                        {
                            type = "button",
                            name = "Remove",
                            width = "full",
                            func = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName] = nil
                                local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList")
                                namesDropdown:UpdateChoices(getPlayerNames())
                            end
                        },
                    },
                },
            },
        },
-------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Grievous Retaliation Alert",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable Overlay",
                    tooltip = "Display *very noticeable* text on screen when anyone is taking damage from rezzing a player whose shade is not killed yet in vCR",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.grievous.enable end,
                    setFunc = function(value) KyzderpsDerps.savedOptions.grievous.enable = value end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Self Only",
                    tooltip = "Show the alert only if you are the one dying from rezzing",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.grievous.selfOnly end,
                    setFunc = function(value) KyzderpsDerps.savedOptions.grievous.selfOnly = value end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Fade Time",
                    tooltip = "Time in milliseconds after the damage taken in which the overlay will fade. Grievous Retaliation ticks every half a second",
                    min = 100,
                    max = 3000,
                    step = 100,
                    default = 1000,
                    width = "full",
                    getFunc = function() return KyzderpsDerps.savedOptions.grievous.timer end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.grievous.timer = value
                    end,
                },
                {
                    type = "description",
                    title = nil,
                    text = "|c99FF99/kdd grievous|r - Toggles Grievous Retaliation overlay (in case it gets stuck)",
                    width = "full",
                },
            }
        },
-------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Boss Timer",
            controls = KyzderpsDerps.SpawnTimer.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Dynamic Events",
            controls = KyzderpsDerps.WorldEvent.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Death Alert",
            controls = KyzderpsDerps.DeathAlert.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Quickslots",
            controls = KyzderpsDerps.QuickSlots.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Companion",
            controls = KyzderpsDerps.Companion.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Combat",
            controls = KyzderpsDerps.Combat.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Anti-Spud",
            controls = {
                {
                    type = "description",
                    title = nil,
                    text = "Don't be a spud! This module notifies you about possible oopsies in your setup.",
                    width = "full",
                },
                {
                    type = "description",
                    title = "|c08BD1DGeneral Settings|r",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Include queued activity",
                    tooltip = "Includes Activity Finder and Cyrodiil/Imperial City campaigns in the PvE/PvP checks. For example, if you queue for a dungeon, AntiSpud will check your mundus as if you were in a PvE activity already. If you queue for a Cyrodiil campaign, AntiSpud will check your mundus as if you were in PvP already",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.state.includeActivityFinder end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.state.includeActivityFinder = value
                        KyzderpsDerps.AntiSpud.CheckState("settings")
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Include in-housing dummy",
                    tooltip = "Considers being in combat with a dummy in player housing as PvE for some checks, e.g. food and mundus",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.state.includeHouseCombatPVE end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.state.includeHouseCombatPVE = value
                        KyzderpsDerps.AntiSpud.CheckState("settings")
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Include in-housing duels",
                    tooltip = "Considers being in PvP combat in player housing as PvP for some checks, e.g. food and mundus",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.state.includeHouseCombatPVP end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.state.includeHouseCombatPVP = value
                        KyzderpsDerps.AntiSpud.CheckState("settings")
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Snooze time",
                    tooltip = "The number of minutes the \"Snooze\" button would snooze the notification for",
                    min = 0,
                    max = 600,
                    step = 10,
                    default = 60,
                    width = "full",
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.snoozeTime / 60 end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.snoozeTime = value * 60
                    end,
                },
                {
                    type = "description",
                    title = "|c08BD1DThings to Check|r",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Check equipped items",
                    tooltip = "Checks your equipped items and notifies you if you are missing pieces, or maybe wearing too many or too few pieces",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.enable end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.equipped.enable = value
                        if (value) then
                            KyzderpsDerps.AntiSpud.InitializeEquipped()
                        else
                            KyzderpsDerps.AntiSpud.UninitializeEquipped()
                        end
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Print equipped sets",
                    tooltip = "Print equipped sets along with how many pieces you are wearing to your chatbox when equipment changes",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.printToChat end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.equipped.printToChat = value
                    end,
                    width = "full",
                    disabled = function()
                        return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                    end,
                },
                {
                    type = "editbox",
                    name = "Set exceptions",
                    tooltip = "Normally, if you are wearing an irregular number of items of a set, AntiSpud will mark it as an error. You can add exact item set names below to exclude them from this rule, for example New Moon Acolyte if you only wear 4 pieces for stat bonuses. Separate item set names with a % sign.",
                    default = "",
                    getFunc = function()
                        local names = {}
                        for name, _ in pairs(KyzderpsDerps.savedOptions.antispud.equipped.fourPieceExceptions) do
                            table.insert(names, name)
                        end
                        return table.concat(names, "%")
                    end,
                    setFunc = function(value)
                        -- Note: I didn't rename the var, but this means general exception now, not just 4-piece. See Equipped.lua
                        KyzderpsDerps.savedOptions.antispud.equipped.fourPieceExceptions = {}
                        for str in string.gmatch(value, "([^%%]+)") do
                            str = string.gsub(str, "^%s+", "")
                            str = string.gsub(str, "%s+$", "")
                            KyzderpsDerps.savedOptions.antispud.equipped.fourPieceExceptions[str] = true
                        end
                    end,
                    isExtraWide = true,
                    isMultiline = true,
                    width = "full",
                    disabled = function()
                        return not KyzderpsDerps.savedOptions.antispud.equipped.enable
                    end,
                },
                {
                    type = "checkbox",
                    name = "Check Spaulder of Ruin",
                    tooltip = "Notifies you if you are wearing Spaulder of Ruin but have not toggled it on",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.equipped.spaulder end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.equipped.spaulder = value
                        KyzderpsDerps.AntiSpud.UpdateSpaulderDisplay()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Check pure class mastery",
                    tooltip = "Notifies you when you have class masteries available but have not allocated the points",
                    multiSelect = true,
                    choices = spudStateChoices,
                    choicesValues = spudStateValues,
                    getFunc = function() return
                        KD.AntiSpud.StateValueToTable(KD.savedOptions.antispud.skills.classMastery)
                    end,
                    setFunc = function(tab)
                        KD.savedOptions.antispud.skills.classMastery = KD.AntiSpud.StateTableToValue(tab)
                        KD.AntiSpud.CheckSkills()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Check food in PvE areas",
                    tooltip = "Notifies you if you don't have a food buff in PvE areas",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.food.pve end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.food.pve = value
                        KyzderpsDerps.AntiSpud.InitializeFood()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Check food in PvP areas",
                    tooltip = "Notifies you if you don't have a food buff in PvP areas",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.food.pvp end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.food.pvp = value
                        KyzderpsDerps.AntiSpud.InitializeFood()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Check food at bosses",
                    tooltip = "Notifies you if you don't have a food buff in boss areas",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.food.boss end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.food.boss = value
                        KyzderpsDerps.AntiSpud.InitializeFood()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Food expiry warning",
                    tooltip = "Approximate number of minutes before your food expires to show a warning (checked every 20 seconds). To not show any warning until the food buff is completely out, set it to 0",
                    min = 0,
                    max = 60,
                    step = 1,
                    default = 5,
                    width = "full",
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.food.prewarn end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.food.prewarn = value
                        KyzderpsDerps.AntiSpud.InitializeFood()
                    end,
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.food.pve and not KyzderpsDerps.savedOptions.antispud.food.pvp and not KyzderpsDerps.savedOptions.antispud.food.boss end,
                },
                {
                    type = "checkbox",
                    name = "Warn food in combat",
                    tooltip = "Whether to warn about upcoming food expiry while in combat. If OFF, the warning will only show outside of combat",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.food.prewarnInCombat end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.food.prewarnInCombat = value
                        KyzderpsDerps.AntiSpud.InitializeFood()
                    end,
                    width = "full",
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.food.pve and not KyzderpsDerps.savedOptions.antispud.food.pvp and not KyzderpsDerps.savedOptions.antispud.food.boss end,
                },
                {
                    type = "checkbox",
                    name = "Check torte in PvP areas",
                    tooltip = "Notifies you if you don't have a torte (Colovian, Molten, White-Gold) buff in PvP areas",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.torte end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.torte = value
                        KyzderpsDerps.AntiSpud.InitializeTorte()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Check encounter log",
                    tooltip = "Notifies you if you are not logging in specific areas",
                    multiSelect = true,
                    choices = spudStateChoices,
                    choicesValues = spudStateValues,
                    getFunc = function() return
                        KD.AntiSpud.StateValueToTable(KD.savedOptions.antispud.log)
                    end,
                    setFunc = function(tab)
                        KD.savedOptions.antispud.log = KD.AntiSpud.StateTableToValue(tab)
                        KD.AntiSpud.CheckLog()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Check Mundus Stone in PvE",
                    tooltip = "Enables the check for PvE: dungeons, trials, and arenas",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.mundus.checkPve end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.mundus.checkPve = value
                        KyzderpsDerps.AntiSpud.CheckMundus()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Allowed PvE Mundus Stones",
                    tooltip = "Mundus Stones that are allowed when you are in a PvE activity",
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        RefreshMundusList()
                        KyzderpsDerps_AntiSpud_MundusPvEAllowed:UpdateChoices(GetMundusNames(mundusPveIds), mundusPveIds)
                    end,
                    setFunc = function(value)
                        selectedPveAllowed = value
                    end,
                    width = "half",
                    reference = "KyzderpsDerps_AntiSpud_MundusPvEAllowed",
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.mundus.checkPve end,
                },
                {
                    type = "button",
                    name = "Remove",
                    tooltip = "Remove the selected Mundus Stone from the allowed PvE list",
                    func = function()
                        if (selectedPveAllowed) then
                            KyzderpsDerps.savedOptions.antispud.mundus.pve[selectedPveAllowed] = nil
                            KyzderpsDerps.AntiSpud.CheckMundus()
                        end
                    end,
                    width = "half",
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.mundus.checkPve end,
                },
                {
                    type = "dropdown",
                    name = "Available PvE Mundus Stones",
                    tooltip = "Mundus Stones that can be added to the allowed PvE list",
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        RefreshMundusList()
                        KyzderpsDerps_AntiSpud_MundusPvEAvailable:UpdateChoices(GetMundusNames(invertedPveIds), invertedPveIds)
                    end,
                    setFunc = function(value)
                        selectedPveAvailable = value
                    end,
                    width = "half",
                    reference = "KyzderpsDerps_AntiSpud_MundusPvEAvailable",
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.mundus.checkPve end,
                },
                {
                    type = "button",
                    name = "Add",
                    tooltip = "Add the selected Mundus Stone to the allowed PvE list",
                    func = function()
                        if (selectedPveAvailable) then
                            KyzderpsDerps.savedOptions.antispud.mundus.pve[selectedPveAvailable] = true
                            KyzderpsDerps.AntiSpud.CheckMundus()
                        end
                    end,
                    width = "half",
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.mundus.checkPve end,
                },
                {
                    type = "checkbox",
                    name = "Check Mundus Stone in PvP",
                    tooltip = "Enables the check for PvP: Cyrodiil, Imperial City, and battlegrounds",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.antispud.mundus.checkPvp end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.antispud.mundus.checkPvp = value
                        KyzderpsDerps.AntiSpud.CheckMundus()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Allowed PvP Mundus Stones",
                    tooltip = "Mundus Stones that are allowed when you are in a PvP activity",
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        RefreshMundusList()
                        KyzderpsDerps_AntiSpud_MundusPvPAllowed:UpdateChoices(GetMundusNames(mundusPvpIds), mundusPvpIds)
                    end,
                    setFunc = function(value)
                        selectedPvpAllowed = value
                    end,
                    width = "half",
                    reference = "KyzderpsDerps_AntiSpud_MundusPvPAllowed",
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.mundus.checkPvp end,
                },
                {
                    type = "button",
                    name = "Remove",
                    tooltip = "Remove the selected Mundus Stone from the allowed PvP list",
                    func = function()
                        if (selectedPvpAllowed) then
                            KyzderpsDerps.savedOptions.antispud.mundus.pvp[selectedPvpAllowed] = nil
                            KyzderpsDerps.AntiSpud.CheckMundus()
                        end
                    end,
                    width = "half",
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.mundus.checkPvp end,
                },
                {
                    type = "dropdown",
                    name = "Available PvP Mundus Stones",
                    tooltip = "Mundus Stones that can be added to the allowed PvP list",
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        RefreshMundusList()
                        KyzderpsDerps_AntiSpud_MundusPvPAvailable:UpdateChoices(GetMundusNames(invertedPvpIds), invertedPvpIds)
                    end,
                    setFunc = function(value)
                        selectedPvpAvailable = value
                    end,
                    width = "half",
                    reference = "KyzderpsDerps_AntiSpud_MundusPvPAvailable",
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.mundus.checkPvp end,
                },
                {
                    type = "button",
                    name = "Add",
                    tooltip = "Add the selected Mundus Stone to the allowed PvP list",
                    func = function()
                        if (selectedPvpAvailable) then
                            KyzderpsDerps.savedOptions.antispud.mundus.pvp[selectedPvpAvailable] = true
                            KyzderpsDerps.AntiSpud.CheckMundus()
                        end
                    end,
                    width = "half",
                    disabled = function() return not KyzderpsDerps.savedOptions.antispud.mundus.checkPvp end,
                },
            }
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Fashion",
            controls = KyzderpsDerps.Fashion.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Chest Forgerrer",
            controls = {
                {
                    type = "description",
                    title = nil,
                    text = "Are you a scatterbrain who can't remember how many chests you've found in this dungeon? Well look no further than the |c99FF99Chest Forgerrer|r! This handy module keeps track of how many chests you've looted in a zone, so it doesn't matter if you |c99FF99FORGOR|r!\nDisclaimer: some chests that are not actually unlockable chests, such as drops from certain bosses, may also be included in the tally. If you loot the same chest twice, it will also be counted twice. Works only for English client.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Print chest interaction",
                    tooltip = "Sends a message in chat when you interact with a chest",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.chatSpam.printChest end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.chatSpam.printChest = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Print chest summary",
                    tooltip = "If you have looted chests in a zone, print a summary of how many chests you looted when leaving the zone",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.chatSpam.printChestSummary end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.chatSpam.printChestSummary = value
                    end,
                    width = "full",
                },
                {
                    type = "description",
                    title = nil,
                    text = "A counter can be shown on the HUD for you even more |c99FF99forgerful|r types.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show chest counter",
                    tooltip = "Shows a counter on the HUD for how many chests you have looted in the current zone",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.infoPanel.chestsLooted end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.infoPanel.chestsLooted = value
                        KyzderpsDerps.ChatSpam.UpdateChestDisplay()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show only in dungeons",
                    tooltip = "Shows the chest counter only in group dungeons",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.infoPanel.chestsLootedDungeonsOnly end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.infoPanel.chestsLootedDungeonsOnly = value
                        KyzderpsDerps.ChatSpam.UpdateChestDisplay()
                    end,
                    width = "full",
                    disabled = function() return not KyzderpsDerps.savedOptions.infoPanel.chestsLooted end,
                },
            }
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Chat Spam",
            controls = {
                {
                    type = "checkbox",
                    name = "Use LibFilteredChatPanel",
                    tooltip = "Send the output of the chat spam to the filtered chat panel instead of regular chat. Requires LibFilteredChatPanel",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.chatSpam.useLFCP end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.chatSpam.useLFCP = value
                    end,
                    width = "full",
                    disabled = function() return LibFilteredChatPanel == nil end,
                },
                {
                    type = "checkbox",
                    name = "Display score gains",
                    tooltip = "Display spammy chat whenever you gain score in veteran scored activities such as trials and arenas",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.chatSpam.printScore end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.chatSpam.printScore = value
                        if (value) then
                            KyzderpsDerps.ChatSpam.RegisterScore()
                        else
                            KyzderpsDerps.ChatSpam.UnregisterScore()
                        end
                    end,
                    width = "full",
                },
            }
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Container Opener",
            controls = KyzderpsDerps.Opener.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Synchronized Memes",
            controls = {
                {
                    type = "description",
                    title = nil,
                    text = "This module allows you and your group members to all use mementos at the same time, or even staggered. It listens for a message of format \"KDD <memento>\" and will then use the memento for you. Use /kddsync command to easily search for mementos.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Ignore while in combat",
                    tooltip = "Do not use mementos while in combat",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.sync.mementos.ignoreInCombat end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.sync.mementos.ignoreInCombat = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Sync mementos from group chat",
                    tooltip = "When you receive a group chat message with a specific format (see /kddsync), automatically use the specified memento. This facilitates synchronized mementos",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.sync.mementos.party end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.sync.mementos.party = value
                        KyzderpsDerps.Sync.Initialize()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Delay before memento",
                    tooltip = "Number of milliseconds to wait after receiving the chat message, before attempting to use the memento",
                    min = 0,
                    max = 5000,
                    step = 10,
                    default = 0,
                    width = "full",
                    getFunc = function() return KyzderpsDerps.savedOptions.sync.mementos.delay end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.sync.mementos.delay = value
                    end,
                },
                {
                    type = "checkbox",
                    name = "Randomize up to delay",
                    tooltip = "Instead of always waiting the above \"Delay before memento\" milliseconds, randomly wait from 0ms up to \"Delay before memento\"",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.sync.mementos.random end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.sync.mementos.random = value
                    end,
                    width = "full",
                },
            }
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "World Icons",
            controls = KyzderpsDerps.WorldIcons.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Pre-Logout",
            controls = KyzderpsDerps.PreLogout.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "User Interface",
            controls = KyzderpsDerps.UIElements.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Dialogue Chatter",
            controls = KyzderpsDerps.Chatter.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Miscellaneous",
            controls = CreateMiscSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "header",
            name = "Other Addon Integrations",
            width = "full",
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Buff The Group",
            controls = CreateBTGSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Hodor Reflexes",
            controls = KyzderpsDerps.Hodor.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "JoGroup",
            controls = KyzderpsDerps.JoGroup.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "More Markers",
            controls = KyzderpsDerps.MoreMarkers.GetSettings(),
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Enable Check",
            controls = KyzderpsDerps.Integrations.GetSettings(),
        },
    }

    KyzderpsDerps.addonPanel = LAM:RegisterAddonPanel("KyzderpsDerpsOptions", panelData)
    LAM:RegisterOptionControls("KyzderpsDerpsOptions", optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", KyzderpsDerps.DeathAlert.HideAllDeathAlert)
end

function KyzderpsDerps.OpenSettingsMenu()
    LibAddonMenu2:OpenToPanel(KyzderpsDerps.addonPanel)
end
