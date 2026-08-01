local addonId = "ScribingWalkthrough"
local class = ZO_InitializingObject:Subclass()

function class:Initialize(name)
    self.name = name
    self.addonData = self:getAddonData()

    _ = scribingWalkthroughQuestWards:New(self)
    _ = scribingWalkthroughQuestWingOfCrow:New(self)
end

local highlightColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT)
local normalColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)
local disabledColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED)
local selectedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
local succeededColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SUCCEEDED)
local failedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED)
local hintColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HINT)
local defaultTextColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DEFAULT_TEXT)
local announcementsColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_ANNOUNCEMENTS)
local gameRepresentativeColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_GAME_REPRESENTATIVE)

function class:Success(message)
    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", hintColor:ToHex(), self:Tag(), succeededColor:ToHex(), message))
end

function class:Error(message)
    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", hintColor:ToHex(), self:Tag(), failedColor:ToHex(), message))
end

function class:Log(message)
    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", hintColor:ToHex(), self:Tag(), gameRepresentativeColor:ToHex(), message))
end

function class:Tag()
    return self.addonData.title
end

function class:getAddonData()
    for index = 1, GetAddOnManager():GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = GetAddOnManager():GetAddOnInfo(index)
        if name == self.name then
            return {
                name = name,
                title = title,
                author = author,
                version = GetAddOnManager():GetAddOnVersion(index),
                directoryPath = GetAddOnManager():GetAddOnRootDirectoryPath(index),
                resolveFilePath = function(relativePath)
                    local str, _ = string.format("%s%s", GetAddOnManager():GetAddOnRootDirectoryPath(index), relativePath):gsub("user:/AddOns", "", 1)
                    return str
                end
            }
        end
    end

    return nil
end

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= addonId then
        return
    end
    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = class:New(addonId)
    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)