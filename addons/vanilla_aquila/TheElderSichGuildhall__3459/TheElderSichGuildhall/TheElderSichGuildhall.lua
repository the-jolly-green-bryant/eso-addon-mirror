SG_Object = ZO_Object:Subclass()

function SG_Object:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function SG_Object:Initialize()
    self.ADDON_NAME = 'TheElderSichGuildhall'
    self.ADDON_VERSION = '1.0'
    self.GUILDHALL_OWNER_ID = '@Anethum'
end

function SG_Object:onLoaded(addonName)
    if addonName == self.ADDON_NAME then
        self:RegisterSlashCommand()
        EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
    end
end

function SG_Object:TeleportToGuildhall()
    JumpToHouse(self.GUILDHALL_OWNER_ID)
end

function SG_Object:RegisterSlashCommand()
   SLASH_COMMANDS['/sgh'] = function(...) self:TeleportToGuildhall(...) end
end

SG = SG_Object:New()

EVENT_MANAGER:RegisterForEvent('TheElderSichGuildhall', EVENT_ADD_ON_LOADED, function(_, addonName) SG:onLoaded(addonName) end)