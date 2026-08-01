Livgardet = {
    db = nil,
    guildId = 664190,
    name = "Livgardet",
    addonName = "Livgardet",
    displayName = "Livgardet |c40c0f0V2.3|r",
    defaults = {
        showChatIcon = true,
        monochromeIcon = false,
        colorizeNames = true,
        noGuildLeave = 0,
    },
    panel = nil,
    chatIcon = nil
}

function Livgardet:Initialize()
    self.db = ZO_SavedVars:NewAccountWide("LivgardetSavedVars", 1, nil, self.defaults, self.version)

    self:InitializeMenu()
    self:InitializeChatIcon()
    self:InitializeNames()
    self:InitializeNoGuildLeave() 
    self:ShowChatIcon(self.db.showChatIcon)
    self:SetChatIconTexture(self.db.monochromeIcon) 
end

function Livgardet.OnAddOnLoaded(_, addon)
    if addon == Livgardet.name then
        Livgardet:Initialize()
        DontReadBooks()
        NoBugs()
        AutoTrader()
 --       AutoClaim()
    end
end

function Livgardet:CheckNoGuildLeave()
    if Livgardet.db.noGuildLeave == 1 and GUILD_HOME.guildId == Livgardet.guildId then
        GUILD_HOME.keybindStripDescriptor[1].visible = function()
            return false
        end
    elseif Livgardet.db.noGuildLeave == 2 then
        GUILD_HOME.keybindStripDescriptor[1].visible = function()
            return false
        end
    else
        GUILD_HOME.keybindStripDescriptor[1].visible = function()
            return true
        end
    end

end

function Livgardet:InitializeNoGuildLeave()
    ZO_PreHook(GUILD_HOME, "RefreshAll", Livgardet.CheckNoGuildLeave)
end


EVENT_MANAGER:RegisterForEvent(Livgardet.name, EVENT_ADD_ON_LOADED, Livgardet.OnAddOnLoaded)

