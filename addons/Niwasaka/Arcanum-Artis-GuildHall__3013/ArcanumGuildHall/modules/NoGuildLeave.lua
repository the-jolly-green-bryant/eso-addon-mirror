local ArcanumGuildHall = _G["ArcanumGuildHall"]

function ArcanumGuildHall:CheckNoGuildLeave()
    if not GUILD_HOME or not GUILD_HOME.keybindStripDescriptor or not GUILD_HOME.keybindStripDescriptor[1] then
        return
    end

    local leaveKeybind = GUILD_HOME.keybindStripDescriptor[1]

    if not self.originalGuildLeaveVisible then
        self.originalGuildLeaveVisible = leaveKeybind.visible
    end

    leaveKeybind.visible = function(...)
        local originalVisible = true

        if type(self.originalGuildLeaveVisible) == "function" then
            originalVisible = self.originalGuildLeaveVisible(...)
        elseif self.originalGuildLeaveVisible ~= nil then
            originalVisible = self.originalGuildLeaveVisible
        end

        if not originalVisible then
            return false
        end

        if self.db.noGuildLeave == 1 and GUILD_HOME.guildId == self.guildId then
            return false
        elseif self.db.noGuildLeave == 2 then
            return false
        end

        return true
    end
end

function ArcanumGuildHall:InitializeNoGuildLeave()
    if self.noGuildLeaveHookRegistered then
        return
    end
    self.noGuildLeaveHookRegistered = true

    ZO_PreHook(GUILD_HOME, "RefreshAll", function()
        self:CheckNoGuildLeave()
    end)
end