local addonId = "Servant"
local class = ZO_InitializingObject:Subclass()

function class:Initialize(name)
    self.name = name
    self.addonData = self:getAddonData()

    self.eventHandler = servantEventHandler:New(self)
    self.settings = servantSettings:New(self)

    self.charge = servantCharge:New(self)
    self.eat = servantEat:New(self)
    self.repair = servantRepair:New(self)
    self.scroll = servantScroll:New(self)
    self.collectible = servantCollectible:New(self)

    SLASH_COMMANDS["/servant-test"] = function(cmd)
        self.collectible:tryUseItem(479)
    end
end

local announcementsColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_ANNOUNCEMENTS)
local succeededColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SUCCEEDED)
local failedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED)
local selectedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
local hintColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HINT)

function class:Log(message)
    if self.settings.data.log ~= true then
        return
    end

    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", announcementsColor:ToHex(), self.addonData.name, succeededColor:ToHex(), message))
end

function class:Error(message)
    if self.settings.data.log ~= true then
        return
    end

    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", announcementsColor:ToHex(), self.addonData.name, failedColor:ToHex(), message))
end

local debugAccounts = {
    ["@zelenin"] = true,
    ["@zelenin_av"] = true,
}

function class:Debug(message)
    if debugAccounts[GetDisplayName()] ~= true then
        return
    end

    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", announcementsColor:ToHex(), self.addonData.name, failedColor:ToHex(), message))
end

function class:TryUseItem(bagId, slotIndex)
    local remain, duration = GetItemCooldownInfo(bagId, slotIndex)
    if remain > 0 and duration > 0 then
        zo_callLater(function()
            self:TryUseItem(bagId, slotIndex)
        end, remain + 100)
        return
    end

    self:Log(string.format("Using %s…", GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)))

    if IsProtectedFunction("UseItem") then
        CallSecureProtected("UseItem", bagId, slotIndex)
    else
        UseItem(bagId, slotIndex)
    end
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

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName ~= addonId then
        return
    end
    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = class:New(addonId)
    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)
