-- IsItTaunted for ESO Console
-- Tracks taunts on enemies and displays remaining time with visual highlights

IsItTaunted = {}
IsItTaunted.name = "IsItTaunted"
IsItTaunted.version = "1.9.10"
IsItTaunted.taunted = {} -- Table to track taunted enemies

-- Default settings
local defaults = {
    fontSize = 24, -- Font size for enemy names and timers
    showOnlyTaunted = true,
    warningTime = 3,
    showAllList = true,
    showHighlights = true, -- Show colored highlights on enemies
    highlightIntensity = 0.8, -- How bright the highlight is (0-1)
    backgroundAlpha = 0, -- Background transparency (0-1, 0 = invisible)
    listOffsetX = -120, -- Horizontal offset from right edge (negative = left)
    listOffsetY = 200, -- Vertical offset from top
    trackGroupTaunts = true, -- Track taunts from all group members
    showTauntSource = true, -- Show who taunted the enemy
    -- Color settings (RGB values 0-1)
    colorSafe = {r = 0.2, g = 1, b = 0.2}, -- Green - more than 5 seconds
    colorCaution = {r = 1, g = 1, b = 0}, -- Yellow - 3-5 seconds
    colorWarning = {r = 1, g = 0.2, b = 0.2}, -- Red - warning time
}

-- Taunt ability IDs (abilities that apply taunt)
local TAUNT_ABILITY_IDS = {
    -- Sword & Board
    [28306] = true, -- Puncture (base)
    [38250] = true, -- Pierce Armor
    [38254] = true, -- Ransack

    -- Undaunted
    [39475] = true, -- Inner Fire (base)
    [42056] = true, -- Inner Rage
    [42060] = true, -- Inner Beast

    -- Ice Staff
    [38989] = true, -- Frost Clench
    [116603] = true, -- Frozen Device

    -- Arcanist
    [183430] = true, -- Runic Sunder
    [186531] = true, -- Runic Embrace
    [183165] = true, -- Runic Jolt

    -- Other
    [40336] = true, -- Silver Leash (Fighters Guild)
    [20496] = true, -- Unrelenting Grip (Dragonknight)
}

-- Taunt debuff IDs (the actual debuff applied to enemies)
local TAUNT_DEBUFF_IDS = {
    [38254] = true, -- Taunt debuff (Ransack)
    [38541] = true, -- Taunt debuff (another variant)
}

-- Known taunt effect names
local TAUNT_EFFECT_NAMES = {
    ["Taunt"] = true,
    ["Taunted"] = true,
}

local DEBUG_MODE = false -- Set to true with /isittaunted debug (WARNING: debug mode uses more memory)

-- Initialize the addon
function IsItTaunted:Initialize()
    self.savedVariables = ZO_SavedVars:NewAccountWide("IsItTauntedSavedVars", 1, nil, defaults)
    
    self:CreateUI()
    
    -- Register for combat events
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

    -- Register for effect changed on reticleover and bosses only
    -- This ensures we only track taunts on visible/targetable units
    EVENT_MANAGER:RegisterForEvent(self.name .. "Reticleover", EVENT_EFFECT_CHANGED, function(...) self:OnEffectChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "Reticleover", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "reticleover")

    for i = 1, 6 do
        EVENT_MANAGER:RegisterForEvent(self.name .. "Boss" .. i, EVENT_EFFECT_CHANGED, function(...) self:OnEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(self.name .. "Boss" .. i, EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_UNIT_TAG, "boss" .. i)
    end
    
    -- Reduce update frequency for better performance (200ms instead of 100ms)
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Update", 200, function() self:OnUpdate() end)
    
    d("IsItTaunted v" .. self.version .. " loaded!")
end

-- Create custom fonts
function IsItTaunted:CreateFonts()
    local fontName = "IsItTauntedFont"
    local fontSize = self.savedVariables.fontSize
    local fontPath = "$(BOLD_FONT)"
    local fontStyle = "soft-shadow-thick"

    self.customFont = fontPath .. "|" .. fontSize .. "|" .. fontStyle
end

-- Create the UI elements
function IsItTaunted:CreateUI()
    local wm = WINDOW_MANAGER

    -- Create custom fonts
    self:CreateFonts()

    -- Create main list container - fixed to right side
    self.listContainer = wm:CreateTopLevelWindow("IsItTauntedListContainer")
    self.listContainer:SetDimensions(380, 400)
    self.listContainer:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, self.savedVariables.listOffsetX, self.savedVariables.listOffsetY)
    self.listContainer:SetMovable(false)
    self.listContainer:SetMouseEnabled(false)
    self.listContainer:SetHidden(true)

    -- Background
    local listBg = wm:CreateControl("$(parent)BG", self.listContainer, CT_BACKDROP)
    listBg:SetAnchorFill()
    listBg:SetCenterColor(0, 0, 0, self.savedVariables.backgroundAlpha)
    listBg:SetEdgeColor(0.5, 0.5, 0.5, 0)
    listBg:SetEdgeTexture("", 8, 2, 2)
    self.listBg = listBg

    -- Title
    self.listTitle = wm:CreateControl("$(parent)Title", self.listContainer, CT_LABEL)
    self.listTitle:SetAnchor(TOP, self.listContainer, TOP, 0, 5)
    self.listTitle:SetFont("ZoFontWinH3")
    self.listTitle:SetText("Taunted Enemies")
    self.listTitle:SetColor(1, 1, 1, 1)
    
    -- Entry container
    self.entryContainer = wm:CreateControl("$(parent)Entries", self.listContainer, CT_CONTROL)
    self.entryContainer:SetAnchor(TOPLEFT, self.listTitle, BOTTOMLEFT, 0, 10)
    self.entryContainer:SetAnchor(BOTTOMRIGHT, self.listContainer, BOTTOMRIGHT, -5, -5)

    self.entries = {}

    -- Create highlight overlay for reticleover
    self.reticleHighlight = wm:CreateTopLevelWindow("IsItTauntedReticleHighlight")
    self.reticleHighlight:SetDimensions(200, 200)
    self.reticleHighlight:SetDrawLayer(DL_OVERLAY)
    self.reticleHighlight:SetDrawTier(DT_MEDIUM)
    self.reticleHighlight:SetMouseEnabled(false)
    self.reticleHighlight:SetHidden(true)
    self.reticleHighlight:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    
    -- Create circular highlight texture
    local highlight = wm:CreateControl("$(parent)Texture", self.reticleHighlight, CT_TEXTURE)
    highlight:SetAnchorFill()
    highlight:SetTexture("/esoui/art/miscellaneous/radialicon_32.dds")
    highlight:SetColor(0, 1, 0, 0.5)
    highlight:SetBlendMode(TEX_BLEND_MODE_ADD)
    self.highlightTexture = highlight

    -- Register settings panel for console/menu access
    self:RegisterSettingsPanel()
end

-- Register settings panel with ESO menu system
function IsItTaunted:RegisterSettingsPanel()
    local panelData = {
        type = "panel",
        name = "Is It Taunted",
        displayName = "Is It Taunted",
        author = "RipleyZephyer",
        version = self.version,
        registerForRefresh = true,
    }

    local optionsData = {
        {
            type = "description",
            text = "Configure taunt tracking display and behavior.",
        },
        {
            type = "header",
            name = "Display Settings",
        },
        {
            type = "slider",
            name = "Font Size",
            tooltip = "Size of enemy names and timers (12-48)",
            min = 12,
            max = 48,
            step = 1,
            getFunc = function() return self.savedVariables.fontSize end,
            setFunc = function(value)
                self.savedVariables.fontSize = value
                self:CreateFonts()
                for i = 1, #self.entries do
                    if self.entries[i] then
                        self.entries[i].nameLabel:SetFont(self.customFont)
                    end
                end
            end,
            default = defaults.fontSize,
        },
        {
            type = "slider",
            name = "Background Transparency",
            tooltip = "Transparency of the list background (0 = invisible, 1 = solid)",
            min = 0,
            max = 1,
            step = 0.05,
            getFunc = function() return self.savedVariables.backgroundAlpha end,
            setFunc = function(value)
                self.savedVariables.backgroundAlpha = value
                if self.listBg then
                    self.listBg:SetCenterColor(0, 0, 0, value)
                end
            end,
            default = defaults.backgroundAlpha,
        },
        {
            type = "checkbox",
            name = "Show Enemy List",
            tooltip = "Display the list of taunted enemies",
            getFunc = function() return self.savedVariables.showAllList end,
            setFunc = function(value) self.savedVariables.showAllList = value end,
            default = defaults.showAllList,
        },
        {
            type = "checkbox",
            name = "Track Group Taunts",
            tooltip = "Track taunts from all group members, not just your own",
            getFunc = function() return self.savedVariables.trackGroupTaunts end,
            setFunc = function(value) self.savedVariables.trackGroupTaunts = value end,
            default = defaults.trackGroupTaunts,
        },
        {
            type = "checkbox",
            name = "Show Who Taunted",
            tooltip = "Display the name of who taunted each enemy",
            getFunc = function() return self.savedVariables.showTauntSource end,
            setFunc = function(value) self.savedVariables.showTauntSource = value end,
            default = defaults.showTauntSource,
        },
        {
            type = "header",
            name = "Position",
        },
        {
            type = "slider",
            name = "Horizontal Position",
            tooltip = "Distance from right edge of screen (negative = left)",
            min = -500,
            max = 0,
            step = 10,
            getFunc = function() return self.savedVariables.listOffsetX end,
            setFunc = function(value)
                self.savedVariables.listOffsetX = value
                self.listContainer:ClearAnchors()
                self.listContainer:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, value, self.savedVariables.listOffsetY)
            end,
            default = defaults.listOffsetX,
        },
        {
            type = "slider",
            name = "Vertical Position",
            tooltip = "Distance from top of screen",
            min = 0,
            max = 1000,
            step = 10,
            getFunc = function() return self.savedVariables.listOffsetY end,
            setFunc = function(value)
                self.savedVariables.listOffsetY = value
                self.listContainer:ClearAnchors()
                self.listContainer:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, self.savedVariables.listOffsetX, value)
            end,
            default = defaults.listOffsetY,
        },
        {
            type = "header",
            name = "Highlight Settings",
        },
        {
            type = "checkbox",
            name = "Show Reticle Highlights",
            tooltip = "Display colored highlight overlay on your current target",
            getFunc = function() return self.savedVariables.showHighlights end,
            setFunc = function(value) self.savedVariables.showHighlights = value end,
            default = defaults.showHighlights,
        },
        {
            type = "slider",
            name = "Highlight Intensity",
            tooltip = "Brightness of the reticle highlight (0-1)",
            min = 0,
            max = 1,
            step = 0.05,
            getFunc = function() return self.savedVariables.highlightIntensity end,
            setFunc = function(value) self.savedVariables.highlightIntensity = value end,
            default = defaults.highlightIntensity,
        },
        {
            type = "header",
            name = "Timer Settings",
        },
        {
            type = "slider",
            name = "Warning Time",
            tooltip = "Show red warning when taunt has this many seconds left",
            min = 1,
            max = 10,
            step = 1,
            getFunc = function() return self.savedVariables.warningTime end,
            setFunc = function(value) self.savedVariables.warningTime = value end,
            default = defaults.warningTime,
        },
        {
            type = "header",
            name = "Color Settings",
        },
        {
            type = "colorpicker",
            name = "Safe Color",
            tooltip = "Color when taunt has more than 5 seconds remaining",
            getFunc = function()
                local c = self.savedVariables.colorSafe
                return c.r, c.g, c.b, 1
            end,
            setFunc = function(r, g, b, a)
                self.savedVariables.colorSafe = {r = r, g = g, b = b}
            end,
            default = {r = 0.2, g = 1, b = 0.2},
        },
        {
            type = "colorpicker",
            name = "Caution Color",
            tooltip = "Color when taunt has 3-5 seconds remaining",
            getFunc = function()
                local c = self.savedVariables.colorCaution
                return c.r, c.g, c.b, 1
            end,
            setFunc = function(r, g, b, a)
                self.savedVariables.colorCaution = {r = r, g = g, b = b}
            end,
            default = {r = 1, g = 1, b = 0},
        },
        {
            type = "colorpicker",
            name = "Warning Color",
            tooltip = "Color when taunt is below warning time threshold",
            getFunc = function()
                local c = self.savedVariables.colorWarning
                return c.r, c.g, c.b, 1
            end,
            setFunc = function(r, g, b, a)
                self.savedVariables.colorWarning = {r = r, g = g, b = b}
            end,
            default = {r = 1, g = 0.2, b = 0.2},
        },
    }

    -- Try to register with LibAddonMenu if available
    if LibAddonMenu2 then
        LibAddonMenu2:RegisterAddonPanel("IsItTauntedSettings", panelData)
        LibAddonMenu2:RegisterOptionControls("IsItTauntedSettings", optionsData)
    end
end

-- Get or create an entry for the list
function IsItTaunted:GetEntry(index)
    if not self.entries[index] then
        local wm = WINDOW_MANAGER
        local entry = wm:CreateControl("IsItTauntedEntry" .. index, self.entryContainer, CT_CONTROL)
        entry:SetDimensions(360, 32)
        entry:SetAnchor(TOPLEFT, self.entryContainer, TOPLEFT, 5, (index - 1) * 36)

        -- Border/backdrop
        entry.backdrop = wm:CreateControl("$(parent)Backdrop", entry, CT_BACKDROP)
        entry.backdrop:SetAnchorFill()
        entry.backdrop:SetCenterColor(0, 0, 0, 0.6)
        entry.backdrop:SetEdgeColor(0.3, 0.3, 0.3, 1)
        entry.backdrop:SetEdgeTexture("", 1, 1, 0)

        -- Progress bar background
        entry.progressBg = wm:CreateControl("$(parent)ProgressBg", entry, CT_TEXTURE)
        entry.progressBg:SetAnchor(TOPLEFT, entry, TOPLEFT, 1, 1)
        entry.progressBg:SetAnchor(BOTTOMRIGHT, entry, BOTTOMRIGHT, -1, -1)
        entry.progressBg:SetTexture("/esoui/art/miscellaneous/progressbar_genericfill.dds")
        entry.progressBg:SetColor(0.1, 0.1, 0.1, 0.8)

        -- Progress bar fill (reverse loading gauge)
        entry.progressBar = wm:CreateControl("$(parent)ProgressBar", entry, CT_TEXTURE)
        entry.progressBar:SetAnchor(TOPLEFT, entry, TOPLEFT, 1, 1)
        entry.progressBar:SetAnchor(BOTTOMLEFT, entry, BOTTOMLEFT, 1, -1)
        entry.progressBar:SetTexture("/esoui/art/miscellaneous/progressbar_genericfill.dds")
        entry.progressBar:SetColor(0.2, 1, 0.2, 0.4)
        entry.progressBar:SetWidth(358)

        -- Combined name and timer label
        entry.nameLabel = wm:CreateControl("$(parent)Name", entry, CT_LABEL)
        entry.nameLabel:SetAnchor(LEFT, entry, LEFT, 8, 0)
        entry.nameLabel:SetFont(self.customFont)
        entry.nameLabel:SetText("")
        entry.nameLabel:SetDrawLayer(DL_TEXT)
        entry.nameLabel:SetDrawTier(DT_HIGH)

        entry:SetHidden(true)
        self.entries[index] = entry
    end
    return self.entries[index]
end

-- Sanitize enemy name to remove special characters
function IsItTaunted:SanitizeName(name)
    if not name then return "Unknown" end
    -- Remove control characters and formatting codes
    name = string.gsub(name, "%^%w", "")  -- Remove ^n, ^p, etc.
    name = string.gsub(name, "%c", "")     -- Remove all control characters
    name = zo_strformat("<<1>>", name)     -- Use ESO's string formatting
    return name
end

-- Get color based on remaining time
function IsItTaunted:GetColorForTime(remaining)
    local color
    if remaining <= self.savedVariables.warningTime then
        color = self.savedVariables.colorWarning -- Red/Warning
    elseif remaining <= 5 then
        color = self.savedVariables.colorCaution -- Yellow/Caution
    else
        color = self.savedVariables.colorSafe -- Green/Safe
    end
    return color.r, color.g, color.b
end

-- Check if source is player or group member
function IsItTaunted:IsGroupMember(sourceType, sourceName)
    -- Always track player's own taunts
    if sourceType == COMBAT_UNIT_TYPE_PLAYER then
        local playerName = GetUnitName("player")
        -- Only return true if it's actually the player, not just any player-type source
        if not sourceName or sourceName == playerName or sourceName == "" then
            return true
        end
    end

    -- If group tracking is disabled, only track player
    if not self.savedVariables.trackGroupTaunts then
        return false
    end

    -- If group tracking is enabled and we're in a group, track all taunts
    if IsUnitGrouped("player") then
        -- For group members, sourceType is also COMBAT_UNIT_TYPE_PLAYER
        -- So if we're grouped and it's a player type, assume it's a group member
        if sourceType == COMBAT_UNIT_TYPE_PLAYER then
            return true
        end

        -- Also check by name matching as fallback
        if sourceName then
            for i = 1, 24 do
                local unitTag = GetGroupUnitTagByIndex(i)
                if unitTag and DoesUnitExist(unitTag) then
                    local memberName = GetUnitName(unitTag)
                    if memberName and (sourceName == memberName or string.find(memberName, sourceName, 1, true)) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- Combat event handler - tracks taunt applications
function IsItTaunted:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,
    powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

    if TAUNT_ABILITY_IDS[abilityId] then
        if DEBUG_MODE then
            d(string.format("[TAUNT ABILITY] SourceName: %s | SourceType: %s | Ability: %s (ID: %d) | Enemy: %s | TargetUnitId: %s",
                sourceName or "None", tostring(sourceType), abilityName or "Unknown", abilityId, targetName or "Unknown", tostring(targetUnitId)))
        end

        -- Determine who applied the taunt
        local playerName = GetUnitName("player")
        local tauntSource

        if sourceName and sourceName ~= "" then
            if sourceName == playerName then
                tauntSource = "You"
            else
                -- It's a group member
                if self.savedVariables.trackGroupTaunts and IsUnitGrouped("player") then
                    tauntSource = sourceName
                else
                    return -- Not tracking group taunts
                end
            end
        else
            -- No source name - try to get it from sourceUnitId
            if sourceUnitId and DoesUnitExist(sourceUnitId) then
                local sourceNameFromId = GetUnitName(sourceUnitId)
                if sourceNameFromId and sourceNameFromId ~= "" then
                    if sourceNameFromId == playerName then
                        tauntSource = "You"
                    else
                        tauntSource = sourceNameFromId
                    end
                else
                    tauntSource = "Group Member"
                end
            elseif sourceType == COMBAT_UNIT_TYPE_PLAYER then
                tauntSource = "You"
            elseif self.savedVariables.trackGroupTaunts and IsUnitGrouped("player") then
                tauntSource = "Group Member"
            else
                return
            end

            if not self.savedVariables.trackGroupTaunts and tauntSource ~= "You" then
                return -- Not tracking group taunts
            end
        end

        -- Get enemy name
        local enemyName = targetName
        if DEBUG_MODE then
            d(string.format("[NAME_CHECK] targetName: %s | targetUnitId: %s | DoesUnitExist: %s",
                tostring(targetName), tostring(targetUnitId), tostring(targetUnitId and DoesUnitExist(targetUnitId))))
        end

        if (not enemyName or enemyName == "") and targetUnitId and DoesUnitExist(targetUnitId) then
            enemyName = GetUnitName(targetUnitId)
            if DEBUG_MODE then
                d(string.format("[NAME_FALLBACK] GetUnitName result: %s", tostring(enemyName)))
            end
        end

        if DEBUG_MODE then
            d(string.format("[TAUNT TRACKED] Who: %s | Enemy: %s | UnitId: %s",
                tauntSource, enemyName or "Unknown", tostring(targetUnitId)))
        end

        -- Track this taunt with the unit ID from the combat event
        if targetUnitId then
            self:TrackTaunt(targetUnitId, enemyName, 15000, tauntSource, abilityName or "Taunt")
        end
    end
end

-- Effect changed handler - handles effects on tracked units (reticleover, boss1-6)
function IsItTaunted:OnEffectChanged(eventCode, changeType, effectSlot, effectName,
    unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType,
    abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    -- Check if this is a taunt debuff or ability
    if abilityId and (TAUNT_DEBUFF_IDS[abilityId] or TAUNT_ABILITY_IDS[abilityId]) then
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            local durationMs = (endTime - beginTime) * 1000
            local tauntSource

            -- Determine who applied the taunt
            if sourceType == COMBAT_UNIT_TYPE_PLAYER then
                tauntSource = "You"
            elseif self.savedVariables.trackGroupTaunts and IsUnitGrouped("player") then
                -- It's a group member's taunt
                tauntSource = "Group Member"
            else
                -- Not tracking this taunt
                return
            end

            -- Get clean enemy name
            local cleanName = zo_strformat("<<1>>", unitName or "Unknown")

            if DEBUG_MODE then
                d(string.format("[TAUNT EFFECT] Who: %s | Ability: %s (ID: %d) | Enemy: %s | Unit: %s | Duration: %.1fs",
                    tauntSource, effectName, abilityId, cleanName, unitTag, durationMs / 1000))
            end

            self:TrackTaunt(unitTag, cleanName, durationMs, tauntSource, effectName)

        elseif changeType == EFFECT_RESULT_FADED then
            if DEBUG_MODE and self.taunted[unitTag] then
                local data = self.taunted[unitTag]
                d(string.format("[TAUNT FADED] Who: %s | Ability: %s | Enemy: %s | Unit: %s",
                    data.source or "You", data.ability or "Unknown", data.name or "Unknown", unitTag))
            end

            -- Only remove if taunt actually faded, not if it was refreshed
            if self.taunted[unitTag] then
                local timeRemaining = self.taunted[unitTag].expireTime - GetGameTimeMilliseconds()
                -- If there's more than 100ms remaining, this is likely a refresh, not a true fade
                if timeRemaining < 100 then
                    self.taunted[unitTag] = nil
                end
            end
        end
    end
end

-- Track a taunted enemy
function IsItTaunted:TrackTaunt(unitId, unitName, durationMs, sourceName, abilityName)
    if not unitId or unitId == "" then return end

    if DEBUG_MODE then
        d(string.format("[TRACK_INPUT] UnitId: %s | UnitName: %s | Source: %s",
            tostring(unitId), tostring(unitName), tostring(sourceName)))
    end

    local currentTime = GetGameTimeMilliseconds()

    -- Convert numeric IDs to unit tags (reticleover, boss1-6) to prevent duplicates
    local isBossTag = (unitId == "reticleover" or string.match(unitId, "^boss%d$"))
    if not isBossTag then
        -- First check reticleover
        if DoesUnitExist("reticleover") then
            local reticleName = GetUnitName("reticleover")
            if unitName and reticleName and unitName ~= "" then
                -- Sanitize both names before comparing
                local cleanUnitName = self:SanitizeName(unitName)
                local cleanReticleName = self:SanitizeName(reticleName)

                if cleanUnitName == cleanReticleName then
                    if DEBUG_MODE then
                        d(string.format("[TRACK_CONSOLIDATE] Converting numeric ID to reticleover (matched: %s)", cleanReticleName))
                    end
                    unitId = "reticleover"
                    isBossTag = true -- Mark as consolidated so we don't check bosses
                end
            end
        end

        -- Then check boss1-6 if not already consolidated
        if not isBossTag then
            for i = 1, 6 do
                local bossTag = "boss" .. i
                if DoesUnitExist(bossTag) then
                    local bossName = GetUnitName(bossTag)
                    if unitName and bossName and unitName ~= "" then
                        -- Sanitize both names before comparing to handle control characters
                        local cleanUnitName = self:SanitizeName(unitName)
                        local cleanBossName = self:SanitizeName(bossName)

                        if cleanUnitName == cleanBossName then
                            if DEBUG_MODE then
                                d(string.format("[TRACK_CONSOLIDATE] Converting numeric ID to %s (matched: %s)", bossTag, cleanBossName))
                            end
                            unitId = bossTag
                            break
                        end
                    end
                end
            end
        end
    end

    -- Normalize source name - if it matches player name, convert to "You"
    local playerName = GetUnitName("player")
    if sourceName and sourceName ~= "" then
        -- Remove control characters from source name before comparing
        local cleanSource = string.gsub(sourceName, "%^%w", "")
        cleanSource = string.gsub(cleanSource, "%c", "")

        if cleanSource == playerName then
            sourceName = "You"
            if DEBUG_MODE then
                d(string.format("[TRACK_NORMALIZE] Source was player name, converted to 'You'"))
            end
        else
            -- Clean the source name even if it's not the player
            sourceName = cleanSource
        end
    end

    -- Try to get name if not provided
    if not unitName or unitName == "" then
        if DoesUnitExist(unitId) then
            unitName = GetUnitName(unitId)
            if DEBUG_MODE then
                d(string.format("[TRACK_GETNAME] Fetched name from unitId: %s", tostring(unitName)))
            end
        end
    end

    local cleanName = self:SanitizeName(unitName)
    local hasControlChar = unitName and string.find(unitName, "%^%w")

    if DEBUG_MODE then
        d(string.format("[TRACK_CLEAN] Original: %s | Cleaned: %s", tostring(unitName), tostring(cleanName)))
    end

    self.taunted[unitId] = {
        name = cleanName,
        expireTime = currentTime + (durationMs or 15000),
        unitId = unitId,
        lastUpdate = currentTime,
        hasControlChar = hasControlChar,
        source = sourceName or "You",
        ability = abilityName or "Unknown"
    }

    if DEBUG_MODE then
        d(string.format("[TRACKED] Unit: %s | Name: %s | Source: %s | Expires: %.1fs",
            unitId, cleanName, sourceName or "You", (durationMs or 15000) / 1000))
    end
end

-- Check if a unit has the taunt debuff
function IsItTaunted:CheckUnitForTaunt(unitTag)
    if not DoesUnitExist(unitTag) then return nil, nil end

    for i = 1, GetNumBuffs(unitTag) do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
              buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)

        -- Check for taunt debuff IDs (primary method) or ability IDs (fallback)
        if abilityId and (TAUNT_DEBUFF_IDS[abilityId] or TAUNT_ABILITY_IDS[abilityId]) then
            -- Check if we should track this taunt
            local shouldTrack = false
            local sourceName = nil

            if castByPlayer then
                -- Always track player's own taunts
                shouldTrack = true
                sourceName = "You"
            elseif self.savedVariables.trackGroupTaunts and IsUnitGrouped("player") then
                -- If group tracking is enabled, track all taunts (including group members)
                shouldTrack = true
                sourceName = "Group Member"
            end

            if shouldTrack then
                local remainingMs = (timeEnding * 1000) - GetGameTimeMilliseconds()
                if remainingMs > 0 then
                    if DEBUG_MODE then
                        d(string.format("[CHECK_BUFF] Found taunt on %s | AbilityID: %d | Remaining: %.1fs | Source: %s | CastByPlayer: %s",
                            unitTag, abilityId, remainingMs / 1000, sourceName, tostring(castByPlayer)))
                    end
                    return remainingMs, sourceName
                end
            end
        end
    end
    return nil, nil
end

-- Update display
function IsItTaunted:OnUpdate()
    local currentTime = GetGameTimeMilliseconds()

    -- First pass: Clean up expired/dead enemies (reduces iterations in next passes)
    local toRemove = {}
    for unitId, data in pairs(self.taunted) do
        local remaining = (data.expireTime - currentTime) / 1000
        local shouldRemove = false
        local isUnitTag = (unitId == "reticleover" or string.match(unitId, "^boss%d$"))
        local unitExists = DoesUnitExist(unitId)

        -- Remove if expired
        if remaining <= 0 then
            shouldRemove = true
        -- Remove if dead (when unit still exists to query)
        elseif unitExists and IsUnitDead(unitId) then
            shouldRemove = true
        -- Remove if it's a unit tag that doesn't exist anymore
        elseif isUnitTag and not unitExists then
            shouldRemove = true
        -- Remove if it's a numeric unit ID that doesn't exist and hasn't been updated recently
        -- (likely dead/despawned - numeric IDs can't be queried when dead)
        elseif not isUnitTag and not unitExists and (currentTime - data.lastUpdate) > 2000 then
            shouldRemove = true
        -- Remove if data is very stale (older than 20 seconds)
        elseif (currentTime - data.lastUpdate) > 20000 then
            shouldRemove = true
        end

        if shouldRemove then
            table.insert(toRemove, unitId)
        end
    end

    -- Remove in separate loop to avoid iterator issues
    for _, unitId in ipairs(toRemove) do
        self.taunted[unitId] = nil
    end

    -- Note: Consolidation disabled - was causing issues with reticleover/boss duplicates
    -- Will rely on TrackTaunt consolidation at entry time instead

    -- Limit total tracked taunts to prevent memory issues (max 20)
    local count = 0
    for _ in pairs(self.taunted) do count = count + 1 end
    if count > 20 then
        -- Remove oldest entries
        local sorted = {}
        for unitId, data in pairs(self.taunted) do
            table.insert(sorted, {unitId = unitId, lastUpdate = data.lastUpdate})
        end
        table.sort(sorted, function(a, b) return a.lastUpdate < b.lastUpdate end)
        for i = 1, count - 20 do
            self.taunted[sorted[i].unitId] = nil
        end
    end

    -- Check visible units (only if we have room to track more)
    if count < 20 then
        local unitsToCheck = {"reticleover", "boss1", "boss2", "boss3", "boss4", "boss5", "boss6"}

        for _, unitTag in ipairs(unitsToCheck) do
            if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) then
                local remainingMs, sourceName = self:CheckUnitForTaunt(unitTag)
                if remainingMs and remainingMs > 0 then
                    local rawName = GetUnitName(unitTag)
                    local cleanName = self:SanitizeName(rawName)
                    local hasControlChar = rawName and string.find(rawName, "%^%w")

                    -- Preserve existing source name if it's more specific
                    local existingSource = self.taunted[unitTag] and self.taunted[unitTag].source
                    local finalSource = sourceName or "You"
                    if existingSource and existingSource ~= "Group Member" and finalSource == "Group Member" then
                        finalSource = existingSource
                    end

                    self.taunted[unitTag] = {
                        name = cleanName,
                        expireTime = currentTime + remainingMs,
                        unitId = unitTag,
                        lastUpdate = currentTime,
                        hasControlChar = hasControlChar,
                        source = finalSource
                    }
                end
            end
        end
    end

    -- Build active display list (reuse table to reduce allocations)
    local allEntries = {}
    for unitId, data in pairs(self.taunted) do
        local remaining = (data.expireTime - currentTime) / 1000

        table.insert(allEntries, {
            name = data.name,
            remaining = remaining,
            unitId = unitId,
            exists = DoesUnitExist(unitId),
            isReticleover = (unitId == "reticleover"),
            hasControlChar = data.hasControlChar,
            source = data.source or "You",
            ability = data.ability or "Unknown"
        })
    end

    -- Remove duplicates: prefer entries without control chars
    -- Group by unitId and name to handle edge cases
    local seen = {}
    local finalEntries = {}

    for i = 1, #allEntries do
        local entry = allEntries[i]
        local key = entry.unitId

        if not seen[key] then
            -- First time seeing this unit
            seen[key] = entry
            table.insert(finalEntries, entry)
        else
            -- Already have an entry for this unit - prefer the one without control chars
            local existing = seen[key]
            if entry.hasControlChar and not existing.hasControlChar then
                -- Keep existing (no control chars)
            elseif not entry.hasControlChar and existing.hasControlChar then
                -- Replace with new entry (no control chars)
                for j = 1, #finalEntries do
                    if finalEntries[j].unitId == key then
                        finalEntries[j] = entry
                        seen[key] = entry
                        break
                    end
                end
            end
            -- If both have or both don't have control chars, keep the first one
        end
    end

    activeEntries = finalEntries

    -- Sort: bosses first, then by remaining time
    table.sort(activeEntries, function(a, b)
        local aIsBoss = string.match(a.unitId, "^boss%d$") ~= nil
        local bIsBoss = string.match(b.unitId, "^boss%d$") ~= nil

        -- If one is a boss and the other isn't, boss comes first
        if aIsBoss and not bIsBoss then
            return true
        elseif bIsBoss and not aIsBoss then
            return false
        else
            -- Both are bosses or both are not bosses, sort by remaining time
            return a.remaining < b.remaining
        end
    end)

    -- Update list display
    if self.savedVariables.showAllList and #activeEntries > 0 then
        for i = 1, #activeEntries do
            local entry = self:GetEntry(i)
            local data = activeEntries[i]

            -- Shorten name if needed
            local displayName = data.name
            local maxNameLength = 25

            -- If showing source, reduce max name length to make room
            if self.savedVariables.showTauntSource then
                maxNameLength = 18
            end

            if #displayName > maxNameLength then
                displayName = string.sub(displayName, 1, maxNameLength - 3) .. "..."
            end

            local timeText = string.format("%.1fs", data.remaining)

            -- Get color for this time
            local r, g, b = self:GetColorForTime(data.remaining)

            -- Convert RGB to hex for color coding
            local colorHex = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)

            -- Combine name and timer with color coding
            local fullText
            if self.savedVariables.showTauntSource then
                -- Format: [who] enemy - time (with purple color for who)
                local purpleColor = "|cBB88FF" -- Purple color
                fullText = purpleColor .. "[" .. (data.source or "You") .. "]|r " .. displayName .. " - " .. colorHex .. timeText .. "|r"
            else
                -- Format: enemy - time
                fullText = displayName .. " - " .. colorHex .. timeText .. "|r"
            end
            entry.nameLabel:SetText(fullText)

            -- Update progress bar (reverse loading - drains from full to empty)
            local maxDuration = 15 -- Taunt duration in seconds
            local percentRemaining = math.min(data.remaining / maxDuration, 1)
            local barWidth = 358 * percentRemaining
            entry.progressBar:SetWidth(barWidth)
            entry.progressBar:SetColor(r, g, b, 0.4)

            -- Dim if not visible
            if not data.exists then
                entry.nameLabel:SetColor(0.6, 0.6, 0.6, 1)
            else
                entry.nameLabel:SetColor(1, 1, 1, 1)
            end

            entry:SetHidden(false)
        end
        
        for i = #activeEntries + 1, #self.entries do
            if self.entries[i] then
                self.entries[i]:SetHidden(true)
            end
        end
        
        self.listContainer:SetHidden(false)
    else
        self.listContainer:SetHidden(true)
    end

    -- Update reticle highlight
    if self.savedVariables.showHighlights then
        local showHighlight = false
        
        for _, data in ipairs(activeEntries) do
            if data.unitId == "reticleover" then
                showHighlight = true
                
                local r, g, b = self:GetColorForTime(data.remaining)
                self.highlightTexture:SetColor(r, g, b, self.savedVariables.highlightIntensity)
                
                break
            end
        end
        
        self.reticleHighlight:SetHidden(not showHighlight)
    else
        self.reticleHighlight:SetHidden(true)
    end
end

-- Slash commands
SLASH_COMMANDS["/isittaunted"] = function(args)
    if args == "list" then
        IsItTaunted.savedVariables.showAllList = not IsItTaunted.savedVariables.showAllList
        d("IsItTaunted enemy list: " .. (IsItTaunted.savedVariables.showAllList and "ON" or "OFF"))
    elseif args == "highlight" then
        IsItTaunted.savedVariables.showHighlights = not IsItTaunted.savedVariables.showHighlights
        d("IsItTaunted enemy highlights: " .. (IsItTaunted.savedVariables.showHighlights and "ON" or "OFF"))
    elseif args:match("^intensity%s+([%d%.]+)") then
        local intensity = tonumber(args:match("^intensity%s+([%d%.]+)"))
        if intensity and intensity >= 0 and intensity <= 1 then
            IsItTaunted.savedVariables.highlightIntensity = intensity
            d("IsItTaunted highlight intensity set to " .. intensity)
        else
            d("Intensity must be between 0 and 1")
        end
    elseif args:match("^alpha%s+([%d%.]+)") then
        local alpha = tonumber(args:match("^alpha%s+([%d%.]+)"))
        if alpha and alpha >= 0 and alpha <= 1 then
            IsItTaunted.savedVariables.backgroundAlpha = alpha
            if IsItTaunted.listBg then
                IsItTaunted.listBg:SetCenterColor(0, 0, 0, alpha)
            end
            d("IsItTaunted background transparency set to " .. alpha)
        else
            d("Alpha must be between 0 and 1")
        end
    elseif args:match("^x%s+([%-]?[%d%.]+)") then
        local x = tonumber(args:match("^x%s+([%-]?[%d%.]+)"))
        if x then
            IsItTaunted.savedVariables.listOffsetX = x
            IsItTaunted.listContainer:ClearAnchors()
            IsItTaunted.listContainer:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, x, IsItTaunted.savedVariables.listOffsetY)
            d("IsItTaunted X position set to " .. x)
        end
    elseif args:match("^y%s+([%-]?[%d%.]+)") then
        local y = tonumber(args:match("^y%s+([%-]?[%d%.]+)"))
        if y then
            IsItTaunted.savedVariables.listOffsetY = y
            IsItTaunted.listContainer:ClearAnchors()
            IsItTaunted.listContainer:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, IsItTaunted.savedVariables.listOffsetX, y)
            d("IsItTaunted Y position set to " .. y)
        end
    elseif args:match("^pos%s+([%-]?[%d%.]+)%s+([%-]?[%d%.]+)") then
        local x, y = args:match("^pos%s+([%-]?[%d%.]+)%s+([%-]?[%d%.]+)")
        x = tonumber(x)
        y = tonumber(y)
        if x and y then
            IsItTaunted.savedVariables.listOffsetX = x
            IsItTaunted.savedVariables.listOffsetY = y
            IsItTaunted.listContainer:ClearAnchors()
            IsItTaunted.listContainer:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, x, y)
            d("IsItTaunted position set to X: " .. x .. ", Y: " .. y)
        end
    elseif args:match("^fontsize%s+([%d]+)") then
        local size = tonumber(args:match("^fontsize%s+([%d]+)"))
        if size and size >= 12 and size <= 48 then
            IsItTaunted.savedVariables.fontSize = size
            IsItTaunted:CreateFonts()
            -- Update all existing entries
            for i = 1, #IsItTaunted.entries do
                if IsItTaunted.entries[i] then
                    IsItTaunted.entries[i].nameLabel:SetFont(IsItTaunted.customFont)
                end
            end
            d("IsItTaunted font size set to " .. size)
        else
            d("Font size must be between 12 and 48")
        end
    elseif args == "reset" then
        IsItTaunted.savedVariables.listOffsetX = -20
        IsItTaunted.savedVariables.listOffsetY = 200
        IsItTaunted.listContainer:ClearAnchors()
        IsItTaunted.listContainer:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -20, 200)
        d("IsItTaunted position reset to default")
    elseif args == "settings" then
        d("IsItTaunted Settings:")
        d("  Enemy list: " .. (IsItTaunted.savedVariables.showAllList and "ON" or "OFF"))
        d("  Enemy highlights: " .. (IsItTaunted.savedVariables.showHighlights and "ON" or "OFF"))
        d("  Highlight intensity: " .. IsItTaunted.savedVariables.highlightIntensity)
        d("  Background transparency: " .. IsItTaunted.savedVariables.backgroundAlpha)
        d("  Font size: " .. IsItTaunted.savedVariables.fontSize)
        d("  Position X: " .. IsItTaunted.savedVariables.listOffsetX)
        d("  Position Y: " .. IsItTaunted.savedVariables.listOffsetY)
        d("  Warning time: " .. IsItTaunted.savedVariables.warningTime .. " seconds")
    elseif args == "debug" then
        DEBUG_MODE = not DEBUG_MODE
        d("IsItTaunted debug: " .. (DEBUG_MODE and "ON (WARNING: uses more memory)" or "OFF"))
    elseif args == "clear" then
        local count = 0
        for _ in pairs(IsItTaunted.taunted) do count = count + 1 end
        IsItTaunted.taunted = {}
        d("IsItTaunted: Cleared " .. count .. " tracked taunts")
    elseif args == "memory" then
        local count = 0
        for _ in pairs(IsItTaunted.taunted) do count = count + 1 end
        d("IsItTaunted Memory:")
        d("  Tracked taunts: " .. count .. " / 20 max")
        d("  Update frequency: 200ms (5 times per second)")
    elseif args == "test" then
        local currentTime = GetGameTimeMilliseconds()
        IsItTaunted.taunted["reticleover"] = {
            name = "Test Wolf",
            expireTime = currentTime + 12000,
            unitId = "reticleover"
        }
        IsItTaunted.taunted["boss1"] = {
            name = "Test Dragon",
            expireTime = currentTime + 8000,
            unitId = "boss1"
        }
        d("Testing with 2 fake enemies for 12s")
    else
        d("IsItTaunted Commands:")
        d("Settings: Menu -> Settings -> Add-ons -> Is It Taunted")
        d("/isittaunted list - Toggle enemy list")
        d("/isittaunted highlight - Toggle enemy highlights")
        d("/isittaunted intensity <0-1> - Set highlight brightness")
        d("/isittaunted alpha <0-1> - Set background transparency")
        d("/isittaunted fontsize <12-48> - Set text size")
        d("/isittaunted x <number> - Set horizontal offset from right")
        d("/isittaunted y <number> - Set vertical offset from top")
        d("/isittaunted pos <x> <y> - Set both X and Y position")
        d("/isittaunted reset - Reset position to default")
        d("/isittaunted settings - Show current settings")
        d("/isittaunted debug - Toggle debug messages (uses more memory)")
        d("/isittaunted clear - Clear all tracked taunts")
        d("/isittaunted memory - Show memory usage stats")
        d("/isittaunted test - Test with fake data")
    end
end

function IsItTaunted.OnAddOnLoaded(event, addonName)
    if addonName == IsItTaunted.name then
        IsItTaunted:Initialize()
        EVENT_MANAGER:UnregisterForEvent(IsItTaunted.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(IsItTaunted.name, EVENT_ADD_ON_LOADED, IsItTaunted.OnAddOnLoaded)
