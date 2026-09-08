-- Title: Tiradil's Guild Assistant
-- Author: Tiradil
-- Copyright: © 2026 Tiradil

TiradilSuite = {}

TiradilSuite.BUILD_TAG = "TGA-QWxjaG9saWNWYWRlcg=="

function TiradilSuite.ToggleWindow()
    if TiradilGuildAssistantWindow:IsHidden() then
        TiradilGuildAssistantWindow:SetHidden(false)
    else
        TiradilGuildAssistantWindow:SetHidden(true)
    end
end

local WINDOW_LAYOUT_REGISTRY = {
    { frameName = "GuildLedgerFrame",           getVars = function() return GuildLedger and GuildLedger.savedVars end },
    { frameName = "TiradilRosterWindow",        getVars = function() return TiradilRoster and TiradilRoster.savedVars end },
    { frameName = "TiradilInactiveWatchWindow", getVars = function() return TiradilInactiveWatch and TiradilInactiveWatch.savedVars end },
    { frameName = "TiradilGuildAssistantWindow",getVars = function() return TiradilSuite.savedVars end },
}

function TiradilSuite.RestoreWindowLayouts()
    for _, entry in ipairs(WINDOW_LAYOUT_REGISTRY) do
        local frame = _G[entry.frameName]
        local vars = entry.getVars and entry.getVars()
        local layout = vars and vars.windowLayout
        if frame and layout and layout.width and layout.height then
            pcall(frame.SetDimensions, frame, layout.width, layout.height)
            if layout.left and layout.top then
                pcall(function()
                    frame:ClearAnchors()
                    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, layout.left, layout.top)
                end)
            end
        end
    end
end

function TiradilSuite.SaveWindowLayouts()
    for _, entry in ipairs(WINDOW_LAYOUT_REGISTRY) do
        local frame = _G[entry.frameName]
        local vars = entry.getVars and entry.getVars()
        if frame and vars then
            vars.windowLayout = {
                width = frame:GetWidth(),
                height = frame:GetHeight(),
                left = frame:GetLeft(),
                top = frame:GetTop(),
            }
        end
    end
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= "TiradilGuildAssistant" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("TiradilGuildAssistant", EVENT_ADD_ON_LOADED)

    TiradilGuildAssistant_SavedVars = TiradilGuildAssistant_SavedVars or {}
    TiradilGuildAssistant_SavedVars.buildOrigin = TiradilGuildAssistant_SavedVars.buildOrigin or TiradilSuite.BUILD_TAG
    TiradilSuite.savedVars = TiradilGuildAssistant_SavedVars

    TiradilRoster.Initialize()
    GuildLedger.Initialize()
    if TiradilInactiveWatch and TiradilInactiveWatch.Initialize then
        TiradilInactiveWatch.Initialize()
    end

    if TiradilL10n and TiradilL10n.RefreshAll then
        TiradilL10n.RefreshAll()
    end

    TiradilGuildAssistantWindow:SetMovable(true)
    pcall(TiradilSuite.RestoreWindowLayouts)

    SLASH_COMMANDS["/tga"] = function() TiradilSuite.ToggleWindow() end
    SLASH_COMMANDS["/tgaledger"] = function() if GuildLedger and GuildLedger.ToggleUI then GuildLedger.ToggleUI() end end
    SLASH_COMMANDS["/tgawatch"] = function() if TiradilInactiveWatch and TiradilInactiveWatch.ToggleWindow then TiradilInactiveWatch.ToggleWindow() end end
    SLASH_COMMANDS["/tgaroster"] = function() if TiradilRosterWindow then TiradilRosterWindow:SetHidden(not TiradilRosterWindow:IsHidden()) end end

    if TiradilGuildButton_TryInitialize then
        pcall(TiradilGuildButton_TryInitialize)
    end

    if TiradilRosterColumn_TryInitialize then
        pcall(TiradilRosterColumn_TryInitialize)
    end
end

EVENT_MANAGER:RegisterForEvent("TiradilGuildAssistant", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

local function OnPlayerDeactivated(eventCode)
    pcall(TiradilSuite.SaveWindowLayouts)
end

EVENT_MANAGER:RegisterForEvent("TiradilGuildAssistant", EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
