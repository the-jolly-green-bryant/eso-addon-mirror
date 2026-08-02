WheresMySulXansBuff = WheresMySulXansBuff or {}
local SXA = WheresMySulXansBuff

SXA.name = "WheresMySulXansBuff"
SXA.displayName = "Where's My Sul-Xan's Buff?"
SXA.version = "2.5.0"
SXA.savedVarsName = "WheresMySulXansBuff_SavedVariables"

local ICON_TEXTURE = "WheresMySulXansBuff/textures/soul_arrow.dds"
local MarkerWindow

local defaults = {
    enabled = true,
    iconSize = 96,
    markerSeconds = 6,
    cooldownSeconds = 6,
    executePercent = 5,
    customReticleIcon = true,
    useEsoTargetMarker = true,
    targetMarkerIcon = 8,
    announce = true,
    debug = false,
    requireSulXanEquipped = true,
}

local function Debug(text)
    if SXA.sv and SXA.sv.debug then
        d(string.format("|c66D9FF[%s]|r %s", SXA.displayName, tostring(text)))
    end
end

local function Announce()
    if not SXA.sv or not SXA.sv.announce then return end
    d("|cB8860B[Where's My Sul-Xan's Buff?]|r |c66D9FFIt's currently on the ground wasting away...|r")
end

local function CreateMarker()
    if MarkerWindow then return MarkerWindow end
    MarkerWindow = WINDOW_MANAGER:CreateTopLevelWindow(SXA.name .. "ReticleIcon")
    MarkerWindow:SetHidden(true)
    MarkerWindow:SetMouseEnabled(false)
    MarkerWindow:SetClampedToScreen(true)
    MarkerWindow:SetDrawLayer(DL_OVERLAY)
    MarkerWindow:SetDrawTier(DT_HIGH)
    MarkerWindow:SetDrawLevel(100)

    MarkerWindow.texture = WINDOW_MANAGER:CreateControl(SXA.name .. "ReticleIconTexture", MarkerWindow, CT_TEXTURE)
    MarkerWindow.texture:SetAnchorFill(MarkerWindow)
    MarkerWindow.texture:SetTexture(ICON_TEXTURE)
    -- Force the custom icon light blue. If the source texture is colored, this still tints it blue.
    MarkerWindow.texture:SetColor(0.40, 0.85, 1.00, 1)
    return MarkerWindow
end

local function SetMarkerSize()
    local size = tonumber(SXA.sv and SXA.sv.iconSize) or defaults.iconSize
    CreateMarker():SetDimensions(size, size)
end

local function HideMarker()
    EVENT_MANAGER:UnregisterForUpdate(SXA.name .. "MarkerHide")
    if MarkerWindow then
        MarkerWindow:SetHidden(true)
        MarkerWindow:ClearAnchors()
    end
end

local function ShowCustomReticleIcon()
    if not SXA.sv or not SXA.sv.customReticleIcon then return end
    local marker = CreateMarker()
    SetMarkerSize()
    marker:ClearAnchors()
    -- This is intentionally a reticle overlay, not a world/corpse marker. It does not use player coordinates.
    marker:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    marker:SetHidden(false)
    local hideAt = GetGameTimeSeconds() + (tonumber(SXA.sv.markerSeconds) or defaults.markerSeconds)
    EVENT_MANAGER:UnregisterForUpdate(SXA.name .. "MarkerHide")
    EVENT_MANAGER:RegisterForUpdate(SXA.name .. "MarkerHide", 100, function()
        if GetGameTimeSeconds() >= hideAt then HideMarker() end
    end)
end

local function IsSulXanEquipped()
    if not SXA.sv or not SXA.sv.requireSulXanEquipped then return true end
    local slots = {
        EQUIP_SLOT_HEAD, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_WAIST,
        EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_HAND, EQUIP_SLOT_NECK,
        EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF,
    }
    local pieces = 0
    for _, slot in ipairs(slots) do
        local itemLink = GetItemLink(BAG_WORN, slot, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local hasSet, setName = GetItemLinkSetInfo(itemLink, false)
            if hasSet and setName then
                local lowerName = zo_strlower(setName)
                if zo_plainstrfind(lowerName, "sul-xan") or zo_plainstrfind(lowerName, "sul xan") then
                    pieces = pieces + 1
                end
            end
        end
    end
    Debug("Sul-Xan/Perfected Sul-Xan equipped pieces detected: " .. tostring(pieces))
    return pieces >= 5
end

local function IsReticleHostile()
    if not DoesUnitExist("reticleover") then return false end
    local okReaction, reaction = pcall(GetUnitReaction, "reticleover")
    return okReaction and reaction == UNIT_REACTION_HOSTILE
end

local function GetReticleHealthPercent()
    local okCur, cur = pcall(GetUnitPower, "reticleover", POWERTYPE_HEALTH)
    local okMax, max = pcall(GetUnitPowerMax, "reticleover", POWERTYPE_HEALTH)
    if not okCur or not okMax or not cur or not max or max <= 0 then return nil end
    return (cur / max) * 100
end

local function CooldownReady(now)
    local cooldown = tonumber(SXA.sv and SXA.sv.cooldownSeconds) or defaults.cooldownSeconds
    if SXA.lastTriggerAt and (now - SXA.lastTriggerAt) < cooldown then
        return false
    end
    return true
end

local function PlaceEsoTargetMarker()
    if not SXA.sv or not SXA.sv.useEsoTargetMarker then return false end
    if type(AssignTargetMarkerToReticleTarget) ~= "function" then
        Debug("AssignTargetMarkerToReticleTarget API is not available.")
        return false
    end
    if not IsReticleHostile() then return false end
    local iconIndex = tonumber(SXA.sv.targetMarkerIcon) or defaults.targetMarkerIcon
    if iconIndex < 1 then iconIndex = 1 end
    if iconIndex > 8 then iconIndex = 8 end
    local ok, err = pcall(AssignTargetMarkerToReticleTarget, iconIndex)
    if not ok then
        Debug("ESO target marker failed safely: " .. tostring(err))
        return false
    end
    Debug("ESO built-in target marker placed on low-health reticle target.")
    return true
end

local function CheckExecuteTarget()
    if not SXA.sv or not SXA.sv.enabled then return end
    if not IsSulXanEquipped() then return end
    if not IsReticleHostile() then return end

    local hp = GetReticleHealthPercent()
    if not hp then return end
    local threshold = tonumber(SXA.sv.executePercent) or defaults.executePercent
    if hp > threshold then return end

    -- Prevent repeated announcements/markers while the target or Sul-Xan soul is on cooldown.
    local now = GetGameTimeSeconds()
    if not CooldownReady(now) then return end
    SXA.lastTriggerAt = now

    PlaceEsoTargetMarker()
    ShowCustomReticleIcon()
    Announce()
end

local function OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType)
    if isError or not SXA.sv or not SXA.sv.enabled then return end
    if result ~= ACTION_RESULT_DIED and result ~= ACTION_RESULT_DIED_XP then return end
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then return end
    if not IsSulXanEquipped() then return end

    -- The execute scanner handles the marker before death. This death handler only starts the cooldown
    -- when YOU get the killing blow so group kills do not spam the add-on.
    local killedByPlayer = sourceType == COMBAT_UNIT_TYPE_PLAYER
    if not killedByPlayer then
        local playerName = GetUnitName("player") or ""
        local playerDisplay = GetDisplayName() or ""
        killedByPlayer = sourceName and sourceName ~= "" and (sourceName == playerName or sourceName == playerDisplay)
    end
    if killedByPlayer then
        local now = GetGameTimeSeconds()
        if CooldownReady(now) then
            SXA.lastTriggerAt = now
            Announce()
        end
    end
end

local function BuildSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end
    local panelData = {
        type = "panel",
        name = SXA.displayName,
        displayName = SXA.displayName,
        author = "Bankroll and @SoldierlyDoc",
        version = SXA.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(SXA.name .. "Options", panelData)
    local options = {
        { type = "description", text = "Custom textures cannot replace ESO's built-in overhead target marker icons. This add-on uses ESO's safe built-in target marker when your reticle target is hostile and at or below the selected health percentage, plus an optional light-blue custom reticle icon." },
        { type = "checkbox", name = "Enable", getFunc = function() return SXA.sv.enabled end, setFunc = function(v) SXA.sv.enabled = v if not v then HideMarker() end end, default = defaults.enabled },
        { type = "slider", name = "Mark enemy at health %", tooltip = "When your hostile reticle target is at or below this health, the add-on attempts to mark it before death so the marker stays on the enemy instead of appearing over you.", min = 1, max = 25, step = 1, getFunc = function() return SXA.sv.executePercent end, setFunc = function(v) SXA.sv.executePercent = v end, default = defaults.executePercent },
        { type = "checkbox", name = "Use ESO built-in target marker", tooltip = "Recommended. This is the only reliable non-error method for an overhead marker on an enemy. ESO does not allow custom textures as target marker icons.", getFunc = function() return SXA.sv.useEsoTargetMarker end, setFunc = function(v) SXA.sv.useEsoTargetMarker = v end, default = defaults.useEsoTargetMarker },
        { type = "slider", name = "ESO target marker icon", tooltip = "Choose the built-in target marker icon number. ESO supports 1 through 8.", min = 1, max = 8, step = 1, getFunc = function() return SXA.sv.targetMarkerIcon end, setFunc = function(v) SXA.sv.targetMarkerIcon = v end, default = defaults.targetMarkerIcon },
        { type = "checkbox", name = "Show custom light-blue reticle icon", tooltip = "Shows your custom icon near the reticle when the target is at or below the health threshold. This is not attached to the corpse/body because ESO does not expose safe hostile corpse coordinates.", getFunc = function() return SXA.sv.customReticleIcon end, setFunc = function(v) SXA.sv.customReticleIcon = v if not v then HideMarker() end end, default = defaults.customReticleIcon },
        { type = "slider", name = "Custom icon size", min = 32, max = 256, step = 4, getFunc = function() return SXA.sv.iconSize end, setFunc = function(v) SXA.sv.iconSize = v SetMarkerSize() end, default = defaults.iconSize },
        { type = "slider", name = "Display duration", tooltip = "How long the custom icon remains visible. Default is 6 seconds.", min = 1, max = 10, step = 1, getFunc = function() return SXA.sv.markerSeconds end, setFunc = function(v) SXA.sv.markerSeconds = v end, default = defaults.markerSeconds },
        { type = "slider", name = "Cooldown", tooltip = "No new announcement or marker attempt until this many seconds passes.", min = 1, max = 15, step = 1, getFunc = function() return SXA.sv.cooldownSeconds end, setFunc = function(v) SXA.sv.cooldownSeconds = v end, default = defaults.cooldownSeconds },
        { type = "checkbox", name = "Announcement", getFunc = function() return SXA.sv.announce end, setFunc = function(v) SXA.sv.announce = v end, default = defaults.announce },
        { type = "checkbox", name = "Require Sul-Xan equipped", tooltip = "Requires at least 5 equipped pieces with Sul-Xan in the set name, including Perfected Sul-Xan.", getFunc = function() return SXA.sv.requireSulXanEquipped end, setFunc = function(v) SXA.sv.requireSulXanEquipped = v end, default = defaults.requireSulXanEquipped },
        { type = "checkbox", name = "Debug messages", getFunc = function() return SXA.sv.debug end, setFunc = function(v) SXA.sv.debug = v end, default = defaults.debug },
    }
    LAM:RegisterOptionControls(SXA.name .. "Options", options)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= SXA.name then return end
    EVENT_MANAGER:UnregisterForEvent(SXA.name, EVENT_ADD_ON_LOADED)
    SXA.sv = ZO_SavedVars:NewAccountWide(SXA.savedVarsName, 1, nil, defaults)
    CreateMarker()
    SetMarkerSize()
    BuildSettings()

    EVENT_MANAGER:RegisterForUpdate(SXA.name .. "ExecuteScanner", 100, CheckExecuteTarget)

    EVENT_MANAGER:RegisterForEvent(SXA.name, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(SXA.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
    EVENT_MANAGER:RegisterForEvent(SXA.name .. "XP", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(SXA.name .. "XP", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)

    SLASH_COMMANDS["/sulxanicon"] = function()
        ShowCustomReticleIcon()
        d("|c66D9FF[Where's My Sul-Xan's Buff?]|r Custom light-blue reticle icon test.")
    end
    SLASH_COMMANDS["/sulxantargetmark"] = function()
        local ok = PlaceEsoTargetMarker()
        d("|c66D9FF[Where's My Sul-Xan's Buff?]|r ESO target marker test: " .. tostring(ok))
    end
    SLASH_COMMANDS["/sulxanpieces"] = function()
        local old = SXA.sv.debug
        SXA.sv.debug = true
        local equipped = IsSulXanEquipped()
        SXA.sv.debug = old
        d("|c66D9FF[Where's My Sul-Xan's Buff?]|r Require equipped check: " .. tostring(equipped))
    end
end

EVENT_MANAGER:RegisterForEvent(SXA.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
