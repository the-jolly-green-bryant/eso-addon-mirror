if ESOAssistant == nil or ESOAssistant.internal == nil then assert(false, "Error on zone module startup: Main module missing!") end
---@type table
local egint = ESOAssistant.internal
local logger = egint.logger
local g_mapPanAndZoom

local function OpenZoneLink(...)
    local mapId = GetCurrentMapId()
    local urlSegments = "zone/" .. mapId
    logger:Debug("Trying OpenZoneLink: %d", mapId)
    egint.ProcessLink(urlSegments)
end

local zoneButtonsKeyboard = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    {
        name = GetString(SI_ESOASSISTANT_SHOW_ZONE),
        keybind = "UI_SHORTCUT_QUINARY",
        callback = OpenZoneLink,
        visible = function()
            return g_mapPanAndZoom:CanMapZoom() and not WORLD_MAP_MANAGER:IsAnimatingDigSites()
        end,
        enabled = function()
            return g_mapPanAndZoom:CanMapZoom() and not WORLD_MAP_MANAGER:IsAnimatingDigSites()
        end,
    },
}

local zoneButtonsGamepad = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name = GetString(SI_ESOASSISTANT_SHOW),
        keybind = "UI_SHORTCUT_QUINARY",
        callback = OpenZoneLink,
        visible = function()
            return not WORLD_MAP_MANAGER:IsPreventingMapNavigation()
        end,
        enabled = function()
            return not WORLD_MAP_MANAGER:IsPreventingMapNavigation()
        end,
    }
}


local keybindsEnabled = false
local function RemoveKeybindStripButton()
    if keybindsEnabled == false then return end
    if IsInGamepadPreferredMode() or ZO_IsConsoleUI() then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(zoneButtonsGamepad)
    else
        KEYBIND_STRIP:RemoveKeybindButtonGroup(zoneButtonsKeyboard)
    end
    keybindsEnabled = false
    if egint.sv.openLink == false then egint.HideQR() end
    logger:Debug("Remove Zone Key Strip Binding.")
end

local function AddKeybindStripButton()
    if keybindsEnabled == true then return end
    if IsInGamepadPreferredMode() or ZO_IsConsoleUI() then
        KEYBIND_STRIP:AddKeybindButtonGroup(zoneButtonsGamepad)
    else
        KEYBIND_STRIP:AddKeybindButtonGroup(zoneButtonsKeyboard)
    end

    logger:Debug("Adding Zone Key Strip Binding.")
    keybindsEnabled = true
end

function egint.initZoneModule()
    ZO_WorldMap:SetHandler("OnShow", AddKeybindStripButton, "ESOAssistant", CONTROL_HANDLER_ORDER_AFTER, "")
    ZO_WorldMap:SetHandler("OnHide", RemoveKeybindStripButton, "ESOAssistant", CONTROL_HANDLER_ORDER_AFTER, "")
    g_mapPanAndZoom = ZO_WorldMap_GetPanAndZoom()
end
